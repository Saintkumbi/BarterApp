import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

// Models
class UserProfile {
  final String name;
  final String location;
  final String bio;
  final String memberSince;
  final String profileImage;
  final List<Badge> badges;
  final bool isVerified;
  final Stats stats;

  UserProfile({
    required this.name,
    required this.location,
    required this.bio,
    required this.memberSince,
    required this.profileImage,
    required this.badges,
    required this.isVerified,
    required this.stats,
  });
}

class Stats {
  final int itemsListed;
  final int successfulTrades;
  final double avgRating;
  final String responseTime;
  final double completionRate;
  final int totalReviews;

  Stats({
    required this.itemsListed,
    required this.successfulTrades,
    required this.avgRating,
    required this.responseTime,
    required this.completionRate,
    required this.totalReviews,
  });
}

class Badge {
  final IconData icon;
  final String label;
  final Color color;

  Badge({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class Review {
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Item {
  final String id;
  final String name;
  final String imagePath;
  final String description;
  final String condition;
  final DateTime listedDate;
  final double rating;
  final String uploadedBy;

  Item({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
    required this.condition,
    required this.listedDate,
    required this.rating,
    required this.uploadedBy,
  });
}

// Main Profile Page Widget
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile userProfile;
  List<Item> items = [
    Item(
      id: '1',
      name: 'Vintage Leather Jacket',
      imagePath: 'lib/assets/LeatherJacket.jpg',
      description:
          'Authentic vintage leather jacket in excellent condition. Perfect for casual wear or collecting.',
      condition: 'Excellent',
      listedDate: DateTime.now().subtract(Duration(days: 5)),
      rating: 4.5,
      uploadedBy: '@VintageCollector',
    ),
    Item(
      id: '2',
      name: 'Handcrafted Wooden Coffee Table',
      imagePath: 'lib/assets/coffeeTable.jpg',
      description: 'Beautiful handcrafted coffee table made from solid wood.',
      condition: 'Excellent',
      listedDate: DateTime.now().subtract(Duration(days: 5)),
      rating: 4.5,
      uploadedBy: '@VintageCollector',
    ),
    Item(
      id: '3',
      name: 'Designer Handbag (Gucci)',
      imagePath: 'lib/assets/gucci.webp',
      description: 'Authentic Gucci handbag in perfect condition.',
      condition: 'Excellent',
      listedDate: DateTime.now().subtract(Duration(days: 5)),
      rating: 4.5,
      uploadedBy: '@VintageCollector',
    ),
  ];

  List<Review> reviews = [
    Review(
      reviewerName: 'John Doe',
      reviewerImage: 'lib/assets/reviewer1.jpg',
      rating: 5.0,
      comment:
          'Great trader! Very responsive and item was exactly as described.',
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeUserProfile();
  }

  void _initializeUserProfile() {
    userProfile = UserProfile(
      name: 'Sarah Johnson',
      location: 'San Francisco, CA',
      bio:
          'Passionate about sustainable trading and finding unique items. Always looking for interesting trades!',
      memberSince: 'March 2024',
      profileImage: 'lib/assets/p2.jpeg',
      isVerified: true,
      badges: [
        Badge(
          icon: Icons.verified_user,
          label: 'Verified Trader',
          color: Colors.blue,
        ),
        Badge(
          icon: Icons.star,
          label: 'Top Rated',
          color: Colors.amber,
        ),
        Badge(
          icon: Icons.speed,
          label: 'Quick Responder',
          color: Colors.green,
        ),
      ],
      stats: Stats(
        itemsListed: 3,
        successfulTrades: 38,
        avgRating: 4.8,
        responseTime: '2h',
        completionRate: 98.5,
        totalReviews: 1,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar()];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            // Handle refresh if needed
            return Future.delayed(Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    SizedBox(height: 16),
                    _buildBadgesList(),
                    SizedBox(height: 24),
                    _buildProfileMetrics(),
                    SizedBox(height: 24),
                    _buildTabBar(),
                  ],
                ),
              ),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/banner.jpeg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => _showEditProfile(),
      ),
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () => _shareProfile(),
      ),
      IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () => _showMoreOptions(),
      ),
    ];
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileImage(),
          SizedBox(height: 16),
          Text(
            userProfile.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildLocationRow(),
          SizedBox(height: 12),
          Text(
            userProfile.bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(userProfile.profileImage),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircularIconButton(
            icon: CupertinoIcons.camera_fill,
            onPressed: () => _updateProfileImage(),
            size: 32,
            backgroundColor: Colors.black,
            iconColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.location_solid,
          size: 16,
          color: Colors.grey,
        ),
        SizedBox(width: 4),
        Text(
          userProfile.location,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        if (userProfile.isVerified) ...[
          SizedBox(width: 8),
          Icon(
            Icons.verified,
            size: 16,
            color: Colors.blue,
          ),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.black,
      tabs: [
        Tab(text: 'Items (${userProfile.stats.itemsListed})'),
        Tab(text: 'Reviews (${userProfile.stats.totalReviews})'),
        Tab(text: 'About'),
      ],
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildItemsGrid(),
          _buildReviewsList(),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  Widget _buildItemCard(Item item) {
    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        item.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index]);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(review.reviewerImage),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildAboutCard(),
        SizedBox(height: 16),
        _buildPreferencesCard(),
        SizedBox(height: 16),
        _buildVerificationCard(),
      ],
    );
  }

  Widget _buildAboutCard() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(userProfile.bio),
            SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Member since',
              value: userProfile.memberSince,
            ),
            _buildInfoRow(
              icon: Icons.location_on,
              title: 'Location',
              value: userProfile.location,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trading Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildPreferenceRow(
              icon: Icons.local_shipping,
              title: 'Shipping',
              value: 'Available',
              isEnabled: true,
            ),
            _buildPreferenceRow(
              icon: Icons.people,
              title: 'In-person Trading',
              value: 'Within 15 miles',
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildVerificationRow(
              title: 'Identity Verified',
              isVerified: true,
              date: 'March 15, 2024',
            ),
            _buildVerificationRow(
              title: 'Email Verified',
              isVerified: true,
              date: 'March 10, 2024',
            ),
            _buildVerificationRow(
              title: 'Phone Verified',
              isVerified: true,
              date: 'March 10, 2024',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isEnabled,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isEnabled ? Colors.black : Colors.grey,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => _updatePreference(title, value),
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow({
    required String title,
    required bool isVerified,
    required String date,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 20,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isVerified ? 'Verified on $date' : 'Pending verification',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            userProfile.badges.map((badge) => _buildBadge(badge)).toList(),
      ),
    );
  }

  Widget _buildBadge(Badge badge) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badge.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 16, color: badge.color),
          SizedBox(width: 4),
          Text(
            badge.label,
            style: TextStyle(
              color: badge.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMetrics() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                icon: Icons.shopping_bag,
                value: userProfile.stats.itemsListed.toString(),
                label: 'Items Listed',
              ),
              _buildStatCard(
                icon: Icons.swap_horiz,
                value: userProfile.stats.successfulTrades.toString(),
                label: 'Trades',
              ),
              _buildStatCard(
                icon: Icons.star,
                value: userProfile.stats.avgRating.toString(),
                label: 'Rating',
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                icon: Icons.timer,
                value: userProfile.stats.responseTime,
                label: 'Response Time',
              ),
              _buildStatCard(
                icon: Icons.verified,
                value: '${userProfile.stats.completionRate}%',
                label: 'Completion',
              ),
              _buildStatCard(
                icon: Icons.message,
                value: userProfile.stats.totalReviews.toString(),
                label: 'Reviews',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Color backgroundColor = Colors.white,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 24),
              SizedBox(height: 8),
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
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updatePreference(String preference, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(preference, value);
      setState(() {
        // Update local state if needed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$preference updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error updating preference: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $preference'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Save updated profile details
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareProfile() {
    // TODO: Implement profile sharing
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // TODO: Implement settings
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help & Support'),
                onTap: () {
                  // TODO: Implement help
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage() async {
    try {
      // Show action sheet for image source selection
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: Colors.green),
                  ),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating profile photo...'),
                ],
              ),
            ),
          );
        },
      );

      // Save image to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(path.join(directory.path, fileName));

      // Dismiss loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile photo updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error updating profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile photo'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showItemDetails(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.black),
                            onPressed: () {
                              // Implement share functionality
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.black),
                            onPressed: () {
                              // Show more options
                            },
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image carousel
                            AspectRatio(
                              aspectRatio: 1,
                              child: PageView.builder(
                                itemCount:
                                    1, // Update when multiple images are supported
                                itemBuilder: (context, index) {
                                  return Hero(
                                    tag: item.imagePath,
                                    child: Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Item details
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.condition,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: AssetImage(
                                            userProfile.profileImage),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        item.uploadedBy,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.star,
                                          size: 20, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text(
                                        item.rating.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement trade request
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Request Trade'),
                                  ),
                                ],
                              ),
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
      },
    );
  }

  Future<void> _loadItems() async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 1));

      // Initialize demo items
      final List<Item> demoItems = [
        Item(
          id: '1',
          name: 'Vintage Leather Jacket',
          imagePath: 'lib/assets/LeatherJacket.jpg',
          description:
              'Authentic vintage leather jacket in excellent condition. Perfect for casual wear or collecting.',
          condition: 'Excellent',
          listedDate: DateTime.now().subtract(Duration(days: 5)),
          rating: 4.5,
          uploadedBy: '@VintageCollector',
        ),
        Item(
          id: '1',
          name: 'Handcrafted Wooden Coffee Table',
          imagePath: 'lib/assets/coffeeTable.jpg',
          description:
              'Authentic vintage leather jacket in excellent condition. Perfect for casual wear or collecting.',
          condition: 'Excellent',
          listedDate: DateTime.now().subtract(Duration(days: 5)),
          rating: 4.5,
          uploadedBy: '@VintageCollector',
        ),
        Item(
          id: '1',
          name: 'Designer Handbag (Gucci)',
          imagePath: 'lib/assets/gucci.webp',
          description:
              'Authentic vintage leather jacket in excellent condition. Perfect for casual wear or collecting.',
          condition: 'Excellent',
          listedDate: DateTime.now().subtract(Duration(days: 5)),
          rating: 4.5,
          uploadedBy: '@VintageCollector',
        ),
        // we will add more demo items...
      ];

      setState(() {
        items = demoItems;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load items'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadReviews() async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 1));

      // Initialize demo reviews
      final List<Review> demoReviews = [
        Review(
          reviewerName: 'John Doe',
          reviewerImage: 'lib/assets/reviewer1.jpg',
          rating: 5.0,
          comment:
              'Great trader! Very responsive and item was exactly as described.',
          date: DateTime.now().subtract(Duration(days: 2)),
        ),
        // we will more demo reviews...
      ];

      setState(() {
        reviews = demoReviews;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load reviews'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Helper widget for circular icon buttons
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CircularIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size * 0.6),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
