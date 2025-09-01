enum TransportType { bicycle, skateboard, scooter }

class TransportModel {
  final String id;
  final TransportType type;
  final String stationId;
  final bool isAvailable;
  final String name;

  TransportModel({
    required this.id,
    required this.type,
    required this.stationId,
    required this.isAvailable,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'stationId': stationId,
      'isAvailable': isAvailable,
      'name': name,
    };
  }

  factory TransportModel.fromMap(Map<String, dynamic> map, String id) {
    return TransportModel(
      id: id,
      type: _parseTransportType(map['type']),
      stationId: map['stationId'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      name: map['name'] ?? '',
    );
  }

  static TransportType _parseTransportType(String type) {
    switch (type) {
      case 'TransportType.bicycle':
        return TransportType.bicycle;
      case 'TransportType.skateboard':
        return TransportType.skateboard;
      case 'TransportType.scooter':
        return TransportType.scooter;
      default:
        return TransportType.bicycle;
    }
  }
}