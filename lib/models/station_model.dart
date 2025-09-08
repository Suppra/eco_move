class StationModel {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final double? latitude;
  final double? longitude;

  StationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory StationModel.fromMap(Map<String, dynamic> map, String id) {
    return StationModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 0,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }
}