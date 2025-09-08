enum TransportType { bicycle, skateboard, scooter }

class TransportModel {
  final String id;
  final TransportType type;
  final String stationId;
  final bool isAvailable;
  final String name;
  final Map<String, dynamic>? characteristics;
  final String? imageUrl; // Nueva propiedad para la imagen

  TransportModel({
    required this.id,
    required this.type,
    required this.stationId,
    required this.isAvailable,
    required this.name,
    this.characteristics,
    this.imageUrl, // Nuevo parámetro opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'stationId': stationId,
      'isAvailable': isAvailable,
      'name': name,
      'characteristics': characteristics,
      'imageUrl': imageUrl, // Agregar imageUrl al mapa
    };
  }

  factory TransportModel.fromMap(Map<String, dynamic> map, String id) {
    return TransportModel(
      id: id,
      type: _parseTransportType(map['type']),
      stationId: map['stationId'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      name: map['name'] ?? '',
      characteristics: map['characteristics']?.cast<String, dynamic>(),
      imageUrl: map['imageUrl'], // Agregar imageUrl del mapa
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

  // Obtener características específicas por tipo
  static Map<String, dynamic> getDefaultCharacteristics(TransportType type) {
    switch (type) {
      case TransportType.bicycle:
        return {
          'marcha': 'Sin marcha',
          'material': 'Acero',
          'peso_kg': 15.0,
          'frenos': 'V-brake',
          'tamano_rueda': '26 pulgadas',
        };
      case TransportType.scooter:
        return {
          'bateria_porcentaje': 100.0,
          'autonomia_km': 25.0,
          'velocidad_max_kmh': 20.0,
          'tiempo_carga_horas': 4.0,
          'peso_kg': 12.0,
        };
      case TransportType.skateboard:
        return {
          'longitud_cm': 80.0,
          'ancho_cm': 20.0,
          'peso_kg': 3.0,
          'material_tabla': 'Madera de arce',
          'tipo_ruedas': 'Poliuretano',
        };
    }
  }
}