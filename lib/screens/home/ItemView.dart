import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:io';
import 'item.dart';
import 'trade.dart';
import 'ConversationPage.dart';
import 'InboxPage.dart';
import 'ExplorePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeRequest {
  final List<Item> offeredItems;
  final Item requestedItem;
  final String status;
  final DateTime timestamp;

  TradeRequest({
    required this.offeredItems,
    required this.requestedItem,
    required this.status,
    required this.timestamp,
  });
}

class ItemView extends StatefulWidget {
  final Item item;

  ItemView({required this.item});

  @override
  _ItemViewState createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLiked = false;
  String userName = '';
  bool _showFullDescription = false;
  final TradePersistenceService _tradePersistenceService =
      TradePersistenceService();
  List<Item> selectedItems = [];

  List<Item> userItems = [
    Item(
        name: 'Vintage Leather Jacket',
        id: '14',
        imagePath: 'lib/assets/LeatherJacket.jpg',
        uploadedBy: '@Fashionista101',
        rating: 3.0),
    Item(
        name: 'Brand New iPhone 14',
        id: '15',
        imagePath: 'lib/assets/iphone14.jpg',
        uploadedBy: '@TechSavvySarah',
        rating: 5.0),
    Item(
        name: 'High-End DSLR Camera',
        id: '16',
        imagePath: 'lib/assets/camera.jpg',
        uploadedBy: '@PhotographerPete',
        rating: 5.0),
  ];
  List<Item> selectedItem = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserName();
    _initializeService();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Future<void> _initializeService() async {
    await _tradePersistenceService.initialize();
  }

  void _showTradeRequestDialog() {
    List<Item> localSelectedItems = List.from(selectedItems);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select Items to Trade',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setModalState(() {
                            localSelectedItems = List.from(selectedItems);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: userItems.length,
                    itemBuilder: (context, index) {
                      final item = userItems[index];
                      final isSelected = localSelectedItems.contains(item);

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color.fromARGB(255, 239, 192, 67)
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < item.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ],
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isSelected
                                ? const Color.fromARGB(255, 239, 192, 67)
                                : Colors.grey,
                          ),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                localSelectedItems.remove(item);
                              } else {
                                localSelectedItems.add(item);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (localSelectedItems.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${localSelectedItems.length} items selected',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: localSelectedItems.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  selectedItems = List.from(localSelectedItems);
                                });
                                Navigator.pop(context);
                                _sendTradeRequest();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.only(
                            top: 11,
                            bottom: 11,
                            left: 45,
                            right: 45,
                          ), // Added padding
                        ),
                        child: Container(
                          child: Text(
                            'Send Trade Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendTradeRequest() async {
    if (selectedItems.isEmpty) return;

    // Create a unique ID for the trade request
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();

    // Get current user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('user_id') ?? userName;

    // Create TradeRequestDTO
    final tradeRequestDTO = TradeRequestDTO(
      id: requestId,
      offeredItemIds: selectedItems.map((item) => item.id).toList(),
      requestedItemId: widget.item.id,
      status: 'pending',
      fromUserId: currentUserId,
      toUserId: widget.item.uploadedBy.replaceAll('@', ''),
      timestamp: DateTime.now(),
    );

    try {
      final success =
          await _tradePersistenceService.createTradeRequest(tradeRequestDTO);

      if (success) {
        _showTradeConfirmation();
        setState(() {
          selectedItems = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send trade request. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending trade request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Helper method to show confirmation
  void _showTradeConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'Trade Request Sent!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The owner will review your request and respond soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            floating: false,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.item.imagePath,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.item.imagePath.startsWith('lib/assets')
                        ? Image.asset(
                            widget.item.imagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(widget.item.imagePath),
                            fit: BoxFit.cover,
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Implement share functionality
                  },
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      AssetImage('lib/assets/p2.jpeg'),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  widget.item.uploadedBy,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.item.rating >= 4
                              ? Colors.green.shade100
                              : widget.item.rating == 3
                                  ? Colors.yellow.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: widget.item.rating >= 4
                                  ? Colors.green.shade700
                                  : widget.item.rating == 3
                                      ? Colors.yellow.shade700
                                      : Colors.red.shade700,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              widget.item.rating.toString(),
                              style: TextStyle(
                                color: widget.item.rating >= 4
                                    ? Colors.green.shade700
                                    : widget.item.rating == 3
                                        ? Colors.yellow.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Details'),
                      Tab(text: 'Owner Info'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(),
                        _buildOwnerTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 45, right: 45, top: 10, bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _showTradeRequestDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 239, 192, 67),
            foregroundColor: Colors.black,
            padding: EdgeInsets.all(11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Request Trade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This is a detailed description of the item. It can be quite long and contain multiple paragraphs of information about the item\'s condition, history, and other relevant details.',
            maxLines: _showFullDescription ? null : 3,
            overflow: _showFullDescription ? null : TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showFullDescription = !_showFullDescription;
              });
            },
            child: Text(
              _showFullDescription ? 'Show Less' : 'Read More',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Item Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildDetailRow('Condition', 'Excellent'),
          _buildDetailRow('Category', 'Electronics'),
          _buildDetailRow('Listed', '2 days ago'),
          _buildDetailRow('Location', 'New York, NY'),
        ],
      ),
    );
  }

  Widget _buildOwnerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage('lib/assets/p2.jpeg'),
          ),
          title: Text(
            widget.item.uploadedBy,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Member since Jan 2024'),
          trailing: ElevatedButton(
            onPressed: () {
              // Implement message functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Message'),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Seller Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.star,
              value: '4.8',
              label: 'Rating',
            ),
            _buildStatItem(
              icon: Icons.sync,
              value: '45',
              label: 'Trades',
            ),
            _buildStatItem(
              icon: Icons.access_time,
              value: '2h',
              label: 'Resp. Time',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.black),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
