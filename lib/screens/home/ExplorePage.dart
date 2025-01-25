import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ItemView.dart';
import 'item.dart';
import 'location.dart';
import 'search.dart';


class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  List<Item> searchResults = [];

  List<Item> items = [
    Item(
        name: 'Vintage Leather Jacket',
        id: '1',
        imagePath: 'lib/assets/LeatherJacket.jpg',
        uploadedBy: '@Fashionista101',
        rating: 3.0),
    Item(
        name: 'Handcrafted Wooden Coffee Table',
        id: '2',
        imagePath: 'lib/assets/coffeeTable.jpg',
        uploadedBy: '@ArtisanMike',
        rating: 4.0),
    Item(
        name: 'Brand New iPhone 14',
        id: '3',
        imagePath: 'lib/assets/iphone14.jpg',
        uploadedBy: '@TechSavvySarah',
        rating: 5.0),
    Item(
        name: 'Rare Vinyl Record Collection',
        id: '4',
        imagePath: 'lib/assets/vinlyRecord.jpeg',
        uploadedBy: '@MusicLover88',
        rating: 5.0),
    Item(
        name: 'High-End DSLR Camera',
        id: '5',
        imagePath: 'lib/assets/camera.jpg',
        uploadedBy: '@PhotographerPete',
        rating: 5.0),
    Item(
        name: 'Designer Handbag (Gucci)',
        id: '8',
        imagePath: 'lib/assets/gucci.webp',
        uploadedBy: '@ChicAndStylish',
        rating: 4),
    Item(
        name: 'Electric Mountain Bike',
        id: '6',
        imagePath: 'lib/assets/bike.jpeg',
        uploadedBy: '@OutdoorAdventurer',
        rating: 5.0),
    Item(
        name: 'Limited Edition Sneakers',
        id: '7',
        imagePath: 'lib/assets/sneaker.webp',
        uploadedBy: '@SneakerheadSam',
        rating: 5.0),
  ];

  List<String> categories = [
    'Home Goods',
    'Fashion & Accessories',
    'Health & Beauty',
    'Sports & Outdoors'
  ];

  void _performSearch() {
    String query = _searchController.text;
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
      searchResults = items
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    FocusScope.of(context).unfocus();
  }

  void _returnToExplore() {
    setState(() {
      isSearching = false;
      searchResults.clear();
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            if (isSearching) _buildBackButton(),
            if (!isSearching) ...[
              _buildBanner(),
              _buildCategories(),
            ],
            Expanded(
              child: isSearching ? _buildSearchResults() : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _returnToExplore,
        icon: Icon(Icons.arrow_back),
        label: Text('Back to Explore'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No items found for "${_searchController.text}"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Search Results (${searchResults.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return _buildProductCard(searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Image.asset(
              'lib/assets/home_logo.png',
              fit: BoxFit.contain,
            ),
          ),
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(items: items), // Pass items here
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 10),
              Text(
                'Search items...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      height: 120,
      width: 500,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'lib/assets/vintageBlack.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
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
              child: Text(
                categories[index],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildProductCard(items[index]);
      },
    );
  }

  Widget _buildProductCard(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemView(
              item: item, // Pass the item directly
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
              child: Image.asset(
                item.imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                item.name,
                style: TextStyle(fontWeight: FontWeight.bold),
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
