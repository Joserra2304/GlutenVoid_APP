

class EstablishmentModel {
  final int id;
  final String name;
  final String description;
  final int phoneNumber;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double rating;
  final bool glutenFreeOption;

  EstablishmentModel({
    required this.id,
    required this.name,
    this.description = '',
    this.phoneNumber = 0,
    this.address = '',
    this.city = '',
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    this.glutenFreeOption = false,
  });

  factory EstablishmentModel.fromJson(Map<String, dynamic> json) {
    return EstablishmentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      city: json['city'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['rating'],
      glutenFreeOption: json['glutenFreeOption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'glutenFreeOption': glutenFreeOption,
    };
  }
}
