
import 'service_model.dart';
import 'package:geolocator/geolocator.dart';

class SalonModel {
  final String name;
  final String description;
  final String address;
  final String imageUrl;
   final String genderType;
    final String rating;
     final String? offer;

  final double latitude;
  final double longitude;
   bool isFavorite;
  final List<ServiceModel> services;

  SalonModel({
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.genderType,
   required this.rating,
   required this.offer,
    required this.latitude,
    required this.longitude,
    required this.services,
    this.isFavorite = false,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      name: json['name'],
      description: json['description'],
      address: json['address'],
      genderType: json['genderType'],
      rating: json['rating'],
      imageUrl: json['imageUrl'],
      offer: json['offer'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      services: (json['services'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'offer':offer,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }

  double distanceFrom(double userLat, double userLon) {
    return Geolocator.distanceBetween(
          userLat,
          userLon,
          latitude,
          longitude,
        ) /
        1000;
  }
}
