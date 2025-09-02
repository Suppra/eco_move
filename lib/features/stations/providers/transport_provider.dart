import 'package:flutter/foundation.dart';
import '../models/transport_model.dart';
import '../models/station_model.dart';
import '../../../services/database_service.dart';

class TransportProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<TransportModel> _transports = [];
  List<StationModel> _stations = [];
  TransportModel? _selectedTransport;
  StationModel? _selectedStation;

  List<TransportModel> get transports => _transports;
  List<StationModel> get stations => _stations;
  TransportModel? get selectedTransport => _selectedTransport;
  StationModel? get selectedStation => _selectedStation;

  TransportProvider() {
    loadTransports();
    loadStations();
  }

  void loadTransports() {
    _databaseService.transports.listen((transports) {
      _transports = transports;
      notifyListeners();
    });
  }

  void loadStations() {
    _databaseService.stations.listen((stations) {
      _stations = stations;
      notifyListeners();
    });
  }

  void setSelectedTransport(TransportModel transport) {
    _selectedTransport = transport;
    notifyListeners();
  }

  void setSelectedStation(StationModel station) {
    _selectedStation = station;
    notifyListeners();
  }

  Stream<List<TransportModel>> getAvailableTransportsByStation(String stationId) {
    return _databaseService.getAvailableTransportsByStation(stationId);
  }

  Future<void> updateTransportAvailability(String transportId, bool isAvailable, String stationId) async {
    await _databaseService.updateTransportAvailability(transportId, isAvailable, stationId);
  }
}