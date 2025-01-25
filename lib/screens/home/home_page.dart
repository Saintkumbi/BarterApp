import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'database_helper.dart';
import 'ItemView.dart';
import 'item.dart';
import 'location.dart';

class home_page extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<home_page> {
  List<Item> items = [];
  String userName = '';

  // Initial hardcoded items
  final List<Item> initialItems = [
    Item(
        id: '10',
        name: '1969 Chevrolet Blazer',
        imagePath: 'lib/assets/carpro1.jpg',
        uploadedBy: 'Davidb123',
        rating: 2),
    Item(
        id: '11',
        name: '1995 Sunseeker 60 Model',
        imagePath: 'lib/assets/boatpro2.jpg',
        uploadedBy: 'greenAlex99',
        rating: 3),
    Item(
        id: '12',
        name: 'Vintage Oyster Rolex Black',
        imagePath: 'lib/assets/watchpro3.JPG',
        uploadedBy: 'VintageCollection',
        rating: 4.0),
    Item(
        id: '13',
        name: 'M2 Macbook pro 16',
        imagePath: 'lib/assets/macpro4.jpeg',
        uploadedBy: 'SarahSarah',
        rating: 5.0),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadItems();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Future<void> _loadItems() async {
    // Start with initial items
    items = List.from(initialItems);

    try {
      final dbItems = await DatabaseHelper.instance.getItems();
      setState(() {
        items.addAll(dbItems.map((item) => Item(
              id: item['id'],
              name: item['name'] as String,
              imagePath: item['imagePath'] as String,
              uploadedBy: item['uploadedBy'] as String,
              rating: (item['rating'] as num).toDouble(),
            )));
      });
      print('Loaded ${dbItems.length} items from database');
    } catch (e) {
      print('Error loading items from database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Location(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    // Update UI with selected location data if applicable
                    print("Selected location: ${result['location']}");
                    print("Search radius: ${result['radius']} km");
                    print("Location type: ${result['type']}");
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.location_solid,
                  size: 20,
                  color: const Color.fromARGB(255, 239, 192, 67),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25),
            Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  String imagePath;
                  switch (index) {
                    case 0:
                      imagePath = 'lib/assets/find_tech.png';
                      break;
                    case 1:
                      imagePath = 'lib/assets/find_chair.png';
                      break;
                    case 2:
                      imagePath = 'lib/assets/find_drill.png';
                      break;
                    default:
                      imagePath = 'lib/assets/find_tech.png';
                  }
                  return GestureDetector(
                    onTap: () {
                      // Add  navigation or action here
                    },
                    child: Container(
                      width: 360,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // will Add action here
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryBox('Home Goods'),
                  _buildCategoryBox('Fashion & Accessories'),
                  _buildCategoryBox('Health & Beauty'),
                  _buildCategoryBox('Sports & Outdoors'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Items you might like',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(items[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBox(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      child: Center(
          child: Text(text, style: TextStyle(fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildItemCard(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemView(
              item: item,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imagePath.startsWith('lib/assets')
                  ? Image.asset(
                      item.imagePath,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(item.imagePath),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          color: Colors.grey,
                          child: Center(child: Text('Image not found')),
                        );
                      },
                    ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'By: ${item.uploadedBy}',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < item.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.black,
                        size: 16,
                      );
                    }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.bubble_left_bubble_right_fill,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
