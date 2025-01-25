import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'ExplorePage.dart';
import 'InboxPage.dart';
import 'ProfilePage.dart';
import 'addPage.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    home_page(),
    ExplorePage(),
    addPage(),
    Inboxpage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border.all(
                // Added border
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Color.fromARGB(255, 235, 235, 235),
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: [
                  _buildNavItem(0, CupertinoIcons.home, 'Home'),
                  _buildNavItem(
                      1, CupertinoIcons.rectangle_grid_3x2, 'Explore'),
                  _buildNavItem(2, CupertinoIcons.plus_circle_fill, '',
                      isLarge: true),
                  _buildNavItem(3, CupertinoIcons.chat_bubble_2, 'Inbox'),
                  _buildNavItem(4, CupertinoIcons.person, 'Profile'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 235, 235, 235),
                ),
                child: Icon(
                  CupertinoIcons.plus_circle_fill,
                  size: 50,
                  color: const Color.fromARGB(255, 239, 192, 67),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, IconData icon, String label,
      {bool isLarge = false}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 5, bottom: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _selectedIndex == index ? 1.0 : 0.8,
              child: Icon(
                icon,
                size: 24,
                color: _selectedIndex == index
                    ? Colors.black
                    : Color.fromARGB(255, 168, 168, 168),
              ),
            ),
            if (_selectedIndex == index && !isLarge)
              Container(height: 2, width: 20, color: Colors.black),
          ],
        ),
      ),
      label: label,
    );
  }
}
