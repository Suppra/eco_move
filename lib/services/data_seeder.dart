import '../models/station_model.dart';
import '../models/transport_model.dart';
import 'database_service.dart';

class DataSeeder {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> seedInitialData() async {
    await _seedStations();
    await _seedTransports();
  }

  Future<void> _seedStations() async {
    final stations = [
      StationModel(
        id: 'station_1',
        name: 'Centro Comercial',
        location: 'Calle 15 #20-30, Centro',
        capacity: 20,
      ),
      StationModel(
        id: 'station_2',
        name: 'Universidad Central',
        location: 'Carrera 10 #25-40, Zona Universitaria',
        capacity: 25,
      ),
      StationModel(
        id: 'station_3',
        name: 'Parque Principal',
        location: 'Plaza Central, Zona Rosa',
        capacity: 15,
      ),
      StationModel(
        id: 'station_4',
        name: 'Terminal de Buses',
        location: 'Avenida Norte #50-100',
        capacity: 30,
      ),
      StationModel(
        id: 'station_5',
        name: 'Zona Empresarial',
        location: 'Carrera 5 #80-20, Sector Financiero',
        capacity: 18,
      ),
    ];

    for (final station in stations) {
      await _databaseService.addStation(station);
    }
  }

  Future<void> _seedTransports() async {
    final transports = [
      // Estación 1 - Centro Comercial
      TransportModel(
        id: 'bike_001',
        type: TransportType.bicycle,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Bicicleta Verde #001',
      ),
      TransportModel(
        id: 'bike_002',
        type: TransportType.bicycle,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Bicicleta Verde #002',
      ),
      TransportModel(
        id: 'skateboard_001',
        type: TransportType.skateboard,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Patineta Eco #001',
      ),
      TransportModel(
        id: 'scooter_001',
        type: TransportType.scooter,
        stationId: 'station_1',
        isAvailable: true,
        name: 'Scooter Eléctrico #001',
      ),

      // Estación 2 - Universidad Central
      TransportModel(
        id: 'bike_003',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta Verde #003',
      ),
      TransportModel(
        id: 'bike_004',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta Verde #004',
      ),
      TransportModel(
        id: 'bike_005',
        type: TransportType.bicycle,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Bicicleta Verde #005',
      ),
      TransportModel(
        id: 'skateboard_002',
        type: TransportType.skateboard,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Patineta Eco #002',
      ),
      TransportModel(
        id: 'skateboard_003',
        type: TransportType.skateboard,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Patineta Eco #003',
      ),
      TransportModel(
        id: 'scooter_002',
        type: TransportType.scooter,
        stationId: 'station_2',
        isAvailable: true,
        name: 'Scooter Eléctrico #002',
      ),

      // Estación 3 - Parque Principal
      TransportModel(
        id: 'bike_006',
        type: TransportType.bicycle,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Bicicleta Verde #006',
      ),
      TransportModel(
        id: 'skateboard_004',
        type: TransportType.skateboard,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Patineta Eco #004',
      ),
      TransportModel(
        id: 'scooter_003',
        type: TransportType.scooter,
        stationId: 'station_3',
        isAvailable: true,
        name: 'Scooter Eléctrico #003',
      ),

      // Estación 4 - Terminal de Buses
      TransportModel(
        id: 'bike_007',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Verde #007',
      ),
      TransportModel(
        id: 'bike_008',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Verde #008',
      ),
      TransportModel(
        id: 'bike_009',
        type: TransportType.bicycle,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Bicicleta Verde #009',
      ),
      TransportModel(
        id: 'skateboard_005',
        type: TransportType.skateboard,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Patineta Eco #005',
      ),
      TransportModel(
        id: 'scooter_004',
        type: TransportType.scooter,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Scooter Eléctrico #004',
      ),
      TransportModel(
        id: 'scooter_005',
        type: TransportType.scooter,
        stationId: 'station_4',
        isAvailable: true,
        name: 'Scooter Eléctrico #005',
      ),

      // Estación 5 - Zona Empresarial
      TransportModel(
        id: 'bike_010',
        type: TransportType.bicycle,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Bicicleta Verde #010',
      ),
      TransportModel(
        id: 'bike_011',
        type: TransportType.bicycle,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Bicicleta Verde #011',
      ),
      TransportModel(
        id: 'skateboard_006',
        type: TransportType.skateboard,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Patineta Eco #006',
      ),
      TransportModel(
        id: 'scooter_006',
        type: TransportType.scooter,
        stationId: 'station_5',
        isAvailable: true,
        name: 'Scooter Eléctrico #006',
      ),
    ];

    for (final transport in transports) {
      await _databaseService.addTransport(transport);
    }
  }
}