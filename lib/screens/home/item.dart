class Item {
  final String id;  // Make id nullable
  final String name;
  final String imagePath;
  final String uploadedBy;
  final double rating;

  Item({
    required this.id,  // Optional id
    required this.name,
    required this.imagePath,
    required this.uploadedBy,
    this.rating = 0.0,
  });


  
}
