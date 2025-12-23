class Island {
  final String name;
  final String imageURL;
  final double price;
  final String time;
  final String departureLocation;
  final String highlights; // if String
  final String packageType;
  final String state;
  final double priceMin;
  final double priceMax;
  final List<String> activitytype;
  final double priceAdult; // Added for Firestore sync
  final double priceChild; // Added for Firestore sync

  Island({
    required this.name,
    required this.imageURL,
    required this.price,
    required this.time,
    required this.departureLocation,
    required this.highlights,
    required this.packageType,
    required this.state,
    required this.priceMin,
    required this.priceMax,
    required this.activitytype,
    required this.priceAdult, // Added to constructor
    required this.priceChild, // Added to constructor
  });

  factory Island.fromMap(Map<String, dynamic> data) {
    return Island(
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      time: data['time'] ?? '',
      departureLocation: data['departureLocation'] ?? '',
      highlights: data['highlights'] ?? '', // FIXED
      packageType: data['packageType'] ?? '',
      state: data['state'] ?? '',
      priceMin: (data['priceMin'] ?? 0).toDouble(),
      priceMax: (data['priceMax'] ?? 0).toDouble(),
      activitytype: List<String>.from(data['activitytype'] ?? []), // FIXED
      priceAdult: (data['priceAdult'] ?? 0).toDouble(), // Added mapping
      priceChild: (data['priceChild'] ?? 0).toDouble(), // Added mapping
    );
  }
}