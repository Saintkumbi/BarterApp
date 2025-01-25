import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ConversationPage.dart';
import 'dart:async';
import 'trade.dart';
import 'item.dart';

class TradeState extends ChangeNotifier {
  static final TradeState _instance = TradeState._internal();
  factory TradeState() => _instance;
  TradeState._internal();

  List<ChatItem> tradeRequests = [];

  void addTradeRequest(TradeRequestDTO tradeRequest, Item requestedItem,
      List<Item> offeredItems) {
    final message = Message(
      content: 'Trade Request',
      isSent: true,
      timestamp: tradeRequest.timestamp,
      type: MessageType.tradeRequest,
      tradeRequest: TradeRequest(
        id: tradeRequest.id,
        offeredItem: offeredItems,
        requestedItem: requestedItem,
        status: tradeRequest.status,
        timestamp: tradeRequest.timestamp,
      ),
    );

    final chatItem = ChatItem(
      id: tradeRequest.id,
      name: requestedItem.uploadedBy,
      lastMessage: 'Trade Request: ${requestedItem.name}',
      time: _formatTime(tradeRequest.timestamp),
      imagePath: requestedItem.imagePath,
      isRead: false,
      messages: [message],
    );

    tradeRequests.add(chatItem);
    notifyListeners();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class Inboxpage extends StatefulWidget {
  @override
  _InboxpageState createState() => _InboxpageState();
}

class _InboxpageState extends State<Inboxpage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TradeState _tradeState;
  String userName = '';
  List<ChatItem> activeChats = [];
  List<ChatItem> tradeRequests = [];
  late StreamSubscription<dynamic> _tradeSubscription;

  final List<ChatItem> allChats = [
    ChatItem(
      id: '1',
      name: 'ArtisanMike',
      lastMessage: 'Trade Request: Vintage Leather Jacket',
      time: '15:43',
      imagePath: 'lib/assets/p4.jpeg',
      isRead: false,
      messages: [
        Message(
          content: 'Hey! I saw your vintage leather jacket.',
          isSent: true,
          timestamp: DateTime.now().subtract(Duration(days: 1)),
        ),
        Message(
          content: 'Yes, it\'s still available!',
          isSent: false,
          timestamp: DateTime.now().subtract(Duration(hours: 23)),
        ),
        Message(
          content:
              'Would you be interested in trading for my custom mechanical keyboard?',
          isSent: true,
          timestamp: DateTime.now().subtract(Duration(hours: 22)),
        ),
      ],
    ),
    ChatItem(
      id: '2',
      name: 'TechSavvySarah',
      lastMessage: 'Perfect! Let\'s meet at 3 PM',
      time: '14:21',
      imagePath: 'lib/assets/p2.jpeg',
      isRead: true,
      messages: [
        Message(
          content: 'Hi, is your MacBook still available?',
          isSent: true,
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tradeState = TradeState();
    _loadUserName();
    _separateChats();

    // Listen to trade state changes
    _tradeState.addListener(() {
      if (mounted) {
        setState(() {
          tradeRequests = [..._tradeState.tradeRequests];
          _separateChats();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tradeState.removeListener(() {});
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  void _separateChats() {
    // Combine existing chats with trade requests
    activeChats = allChats
        .where((chat) => !chat.lastMessage.contains('Trade Request:'))
        .toList();
    tradeRequests = [
      ...allChats.where((chat) => chat.lastMessage.contains('Trade Request:')),
      ..._tradeState.tradeRequests,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color.fromARGB(255, 239, 192, 67),
              tabs: [
                Tab(text: 'Messages'),
                Tab(text: 'Trade Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessagesList(activeChats),
                  _buildTradeRequestsList(tradeRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Spacer(flex: 1),
          SizedBox(
            width: 90,
            height: 90,
            child: Image.asset(
              'lib/assets/home_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          Spacer(flex: 2),
          NotificationIcon()
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatItem> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return _buildChatItem(chats[index]);
      },
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationPage(chatItem: chat)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(chat.imagePath),
                    ),
                  ),
                ),
                if (!chat.isRead)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      color: chat.isRead ? Colors.grey : Colors.black,
                      fontWeight:
                          chat.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeRequestsList(List<ChatItem> requests) {
    // Adding mock data for demonstration
    final mockRequests = [
      ...requests,
      ChatItem(
        id: 'rejected-mock',
        name: 'Sara',
        lastMessage: 'Trade Request: Gaming Console',
        time: '2h ago',
        imagePath: 'lib/assets/p5.jpeg',
        isRead: false,
        messages: [
          Message(
            content: 'Trade Request',
            isSent: true,
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
            type: MessageType.tradeRequest,
            tradeRequest: TradeRequest(
              id: 'rejected-mock',
              offeredItem: [
                Item(
                  id: 'item1',
                  name: 'PlayStation 5',
                  imagePath: 'lib/assets/ps5.jpg',
                  uploadedBy: '@JohnDoe',
                  rating: 4.5,
                ),
              ],
              requestedItem: Item(
                id: 'item2',
                name: 'Gaming Console',
                imagePath: 'lib/assets/console.jpg',
                uploadedBy: '@GameMaster',
                rating: 4.8,
              ),
              status: 'rejected',
              timestamp: DateTime.now().subtract(Duration(hours: 2)),
            ),
          ),
        ],
      ),
      ChatItem(
        id: 'approved-mock',
        name: 'Jessica',
        lastMessage: 'Trade Request: Vintage Camera',
        time: '1h ago',
        imagePath: 'lib/assets/p2.jpeg',
        isRead: false,
        messages: [
          Message(
            content: 'Trade Request',
            isSent: true,
            timestamp: DateTime.now().subtract(Duration(hours: 1)),
            type: MessageType.tradeRequest,
            tradeRequest: TradeRequest(
              id: 'approved-mock',
              offeredItem: [
                Item(
                  id: 'item3',
                  name: 'DSLR Camera',
                  imagePath: 'lib/assets/camera.jpg',
                  uploadedBy: '@AliceSmith',
                  rating: 4.9,
                ),
              ],
              requestedItem: Item(
                id: 'item4',
                name: 'Vintage Camera',
                imagePath: 'lib/assets/vintage_camera.jpg',
                uploadedBy: '@PhotoPro',
                rating: 4.7,
              ),
              status: 'accepted',
              timestamp: DateTime.now().subtract(Duration(hours: 1)),
            ),
          ),
        ],
      ),
    ];

    return ListView.builder(
      itemCount: mockRequests.length,
      itemBuilder: (context, index) {
        return _buildTradeRequestItem(mockRequests[index]);
      },
    );
  }

  Widget _buildTradeRequestItem(ChatItem request) {
    final tradeRequest = request.messages
        .firstWhere(
          (m) => m.type == MessageType.tradeRequest,
          orElse: () => request.messages.first,
        )
        .tradeRequest;

    // Determine card style based on status
    Color borderColor;
    Color statusBgColor;
    Color statusTextColor;
    Color cardBgColor; // Added background color
    switch (tradeRequest?.status.toLowerCase()) {
      case 'rejected':
        borderColor = Colors.red.shade300;
        statusBgColor = Colors.red.shade100;
        statusTextColor = Colors.red.shade900;
        cardBgColor = Colors.red.shade50;
        break;
      case 'accepted':
        borderColor = Colors.green.shade300;
        statusBgColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade900;
        cardBgColor = Colors.green.shade50;
        break;
      default:
        borderColor = const Color.fromARGB(255, 239, 192, 67);
        statusBgColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade900;
        cardBgColor = Colors.orange.shade50;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      color: cardBgColor, // Set the card's background color
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationPage(chatItem: request)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(request.imagePath),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (tradeRequest != null)
                              Text(
                                'Offering: ${tradeRequest.offeredItem.map((item) => item.name).join(", ")}',
                                style: TextStyle(color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            request.time,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tradeRequest?.status.toUpperCase() ?? 'PENDING',
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (tradeRequest?.status.toLowerCase() == 'accepted')
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.7), // Semi-transparent white
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade100,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              color: Colors.green.shade700, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tap to begin chatting about the trade',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  int notificationCount =
      2; // Initial count (can be fetched from a backend or local storage)

  // Simulate updating the count (you can replace this with your logic)
  void _incrementNotifications() {
    setState(() {
      notificationCount++;
    });
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4, // Start with 40% of screen height
          maxChildSize: 0.8, // Expand to 80% of screen height
          minChildSize: 0.2, // Collapse to 20% of screen height
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildNotificationCard(
                          icon: Icons.done,
                          title: 'Trade Finalized',
                          subtitle: 'Your trade with Jessica is complete.',
                          color: Colors.green.shade100,
                          iconColor: Colors.green.shade700,
                        ),
                        _buildNotificationCard(
                          icon: Icons.done,
                          title: 'Trade Finalized',
                          subtitle: 'Your trade with ArtisanMike is complete.',
                          color: Colors.green.shade100,
                          iconColor: Colors.green.shade700,
                        ),
                        _buildNotificationCard(
                          icon: Icons.close,
                          title: 'Trade Rejected',
                          subtitle:
                              'Your trade offer for the DSLR Camera was declined.',
                          color: Colors.red.shade100,
                          iconColor: Colors.red.shade700,
                        ),
                        _buildNotificationCard(
                          icon: Icons.notifications_active,
                          title: 'New Trade Proposal',
                          subtitle:
                              'Sara submitted a trade proposal for your Vintage Jacket.',
                          color: Colors.orange.shade100,
                          iconColor: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Notification Bell Icon
        GestureDetector(
          onTap: () {
            _showNotifications(context);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.bell_solid,
              size: 20,
              color: const Color.fromARGB(255, 239, 192, 67),
            ),
          ),
        ),
        // Notification Badge
        if (notificationCount > 0) // Show only if there are notifications
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$notificationCount', // Dynamic count
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
