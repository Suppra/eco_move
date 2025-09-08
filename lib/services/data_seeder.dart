import '../models/station_model.dart';
import '../models/transport_model.dart';
import 'database_service.dart';

class DataSeeder {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> seedInitialData() async {
    // Limpiar datos existentes primero
    await _databaseService.clearTestData();
    
    // Insertar nuevos datos
    await _seedStations();
    await _seedTransports();
  }

  Future<void> _seedStations() async {
    final stations = [
      StationModel(
        id: 'station_1',
        name: 'Plaza Alfonso López',
        location: 'Plaza Alfonso López, Centro, Valledupar, César',
        capacity: 25,
        latitude: 10.4631,
        longitude: -73.2535,
      ),
      StationModel(
        id: 'station_2',
        name: 'Universidad Popular del Cesar',
        location: 'Cra. 6 #23-55, Valledupar, César',
        capacity: 30,
        latitude: 10.4789,
        longitude: -73.2456,
      ),
      StationModel(
        id: 'station_3',
        name: 'Centro Comercial Guatapurí Plaza',
        location: 'Cl. 16A #5-129, Valledupar, César',
        capacity: 20,
        latitude: 10.4745,
        longitude: -73.2487,
      ),
      StationModel(
        id: 'station_4',
        name: 'Terminal de Transportes',
        location: 'Carrera 7, Valledupar, César',
        capacity: 35,
        latitude: 10.4534,
        longitude: -73.2398,
      ),
      StationModel(
        id: 'station_5',
        name: 'Parque de la Leyenda Vallenata',
        location: 'Cra. 9 #13-65, Valledupar, César',
        capacity: 22,
        latitude: 10.4689,
        longitude: -73.2511,
      ),
      StationModel(
        id: 'station_6',
        name: 'Hospital Eduardo Arredondo Daza',
        location: 'Cra. 16A #18A-261, Valledupar, César',
        capacity: 18,
        latitude: 10.4712,
        longitude: -73.2443,
      ),
      StationModel(
        id: 'station_7',
        name: 'Estadio Armando Maestre Pavajeau',
        location: 'Cl. 12 #19-63, Valledupar, César',
        capacity: 28,
        latitude: 10.4658,
        longitude: -73.2398,
      ),
    ];

    for (final station in stations) {
      await _databaseService.addStation(station);
    }
  }

  Future<void> _seedTransports() async {
    final transports = [
      // Estación 1 - Plaza Alfonso López
      TransportModel(
        id: 'bike_001',
        type: TransportType.bicycle,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Bicicleta Vallenata #001',
      ),
      TransportModel(
        id: 'bike_002',
        type: TransportType.bicycle,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Bicicleta Vallenata #002',
      ),
      TransportModel(
        id: 'skateboard_001',
        type: TransportType.skateboard,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Patineta Plaza #001',
      ),
      TransportModel(
        id: 'scooter_001',
        type: TransportType.scooter,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Scooter Centro #001',
      ),

      // Estación 2 - Universidad Popular del Cesar
      TransportModel(
        id: 'bike_003',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta UPC #003',
      ),
      TransportModel(
        id: 'bike_004',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta UPC #004',
      ),
      TransportModel(
        id: 'bike_005',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta UPC #005',
      ),
      TransportModel(
        id: 'skateboard_002',
        type: TransportType.skateboard,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Patineta Universitaria #002',
      ),
      TransportModel(
        id: 'skateboard_003',
        type: TransportType.skateboard,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Patineta Universitaria #003',
      ),
      TransportModel(
        id: 'scooter_002',
        type: TransportType.scooter,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Scooter Estudiantil #002',
      ),

      // Estación 3 - Centro Comercial Guatapurí Plaza
      TransportModel(
        id: 'bike_006',
        type: TransportType.bicycle,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Bicicleta Guatapurí #006',
      ),
      TransportModel(
        id: 'bike_007',
        type: TransportType.bicycle,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Bicicleta Guatapurí #007',
      ),
      TransportModel(
        id: 'skateboard_004',
        type: TransportType.skateboard,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Patineta Mall #004',
      ),
      TransportModel(
        id: 'scooter_003',
        type: TransportType.scooter,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Scooter Shopping #003',
      ),

      // Estación 4 - Terminal de Transportes
      TransportModel(
        id: 'bike_008',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Terminal #008',
      ),
      TransportModel(
        id: 'bike_009',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Terminal #009',
      ),
      TransportModel(
        id: 'bike_010',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Terminal #010',
      ),
      TransportModel(
        id: 'skateboard_005',
        type: TransportType.skateboard,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Patineta Viajero #005',
      ),
      TransportModel(
        id: 'scooter_004',
        type: TransportType.scooter,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Scooter Express #004',
      ),
      TransportModel(
        id: 'scooter_005',
        type: TransportType.scooter,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Scooter Express #005',
      ),

      // Estación 5 - Parque de la Leyenda Vallenata
      TransportModel(
        id: 'bike_011',
        type: TransportType.bicycle,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Bicicleta Leyenda #011',
      ),
      TransportModel(
        id: 'bike_012',
        type: TransportType.bicycle,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Bicicleta Leyenda #012',
      ),
      TransportModel(
        id: 'skateboard_006',
        type: TransportType.skateboard,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Patineta Cultural #006',
      ),
      TransportModel(
        id: 'scooter_006',
        type: TransportType.scooter,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Scooter Folclórico #006',
      ),

      // Estación 6 - Hospital Eduardo Arredondo Daza
      TransportModel(
        id: 'bike_013',
        type: TransportType.bicycle,
        stationId: 'station_6',
        isAvailable: true,
        name: 'Bicicleta Salud #013',
      ),
      TransportModel(
        id: 'bike_014',
        type: TransportType.bicycle,
        stationId: 'station_6',
        isAvailable: true,
        name: 'Bicicleta Salud #014',
      ),
      TransportModel(
        id: 'scooter_007',
        type: TransportType.scooter,
        stationId: 'station_6',
        isAvailable: true,
        name: 'Scooter Médico #007',
      ),

      // Estación 7 - Estadio Armando Maestre Pavajeau
      TransportModel(
        id: 'bike_015',
        type: TransportType.bicycle,
        stationId: 'station_7',
        isAvailable: true,
        name: 'Bicicleta Deportiva #015',
      ),
      TransportModel(
        id: 'bike_016',
        type: TransportType.bicycle,
        stationId: 'station_7',
        isAvailable: true,
        name: 'Bicicleta Deportiva #016',
      ),
      TransportModel(
        id: 'skateboard_007',
        type: TransportType.skateboard,
        stationId: 'station_7',
        isAvailable: true,
        name: 'Patineta Atlética #007',
      ),
      TransportModel(
        id: 'skateboard_008',
        type: TransportType.skateboard,
        stationId: 'station_7',
        isAvailable: true,
        name: 'Patineta Atlética #008',
      ),
      TransportModel(
        id: 'scooter_008',
        type: TransportType.scooter,
        stationId: 'station_7',
        isAvailable: true,
        name: 'Scooter Stadium #008',
      ),
    ];

    for (final transport in transports) {
      await _databaseService.addTransport(transport);
    }
  }
}