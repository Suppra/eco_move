import 'package:flutter/foundation.dart';
import '../models/transport_model.dart';
import '../models/station_model.dart';
import '../services/database_service.dart';

class TransportProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<TransportModel> _transports = [];
  List<StationModel> _stations = [];
  Map<String, List<TransportModel>> _stationTransports = {};
  Map<TransportType, int> _stationAvailability = {};
  TransportModel? _selectedTransport;
  StationModel? _selectedStation;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TransportModel> get transports => _transports;
  List<StationModel> get stations => _stations;
  Map<String, List<TransportModel>> get stationTransports => _stationTransports;
  Map<TransportType, int> get stationAvailability => _stationAvailability;
  TransportModel? get selectedTransport => _selectedTransport;
  StationModel? get selectedStation => _selectedStation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TransportProvider() {
    _initializeData();
  }

  void _initializeData() {
    loadStations();
    loadTransports();
  }

  // Cargar todas las estaciones
  Future<void> loadStations() async {
    _setLoading(true);
    try {
      _databaseService.stations.listen((stations) {
        _stations = stations;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar estaciones: $e';
      notifyListeners();
    }
    _setLoading(false);
  }

  // Cargar todos los transportes
  Future<void> loadTransports() async {
    _setLoading(true);
    try {
      _databaseService.transports.listen((transports) {
        _transports = transports;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar transportes: $e';
      notifyListeners();
    }
    _setLoading(false);
  }

  // Cargar transportes de una estación específica
  Future<void> loadStationTransports(String stationId) async {
    try {
      _databaseService.getTransportsByStation(stationId).listen((transports) {
        _stationTransports[stationId] = transports;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar transportes de estación: $e';
      notifyListeners();
    }
  }

  // Cargar disponibilidad de una estación
  Future<void> loadStationAvailability(String stationId) async {
    try {
      final availability = await _databaseService.getStationAvailability(stationId);
      _stationAvailability = availability;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar disponibilidad: $e';
      notifyListeners();
    }
  }

  // Seleccionar transporte
  void selectTransport(TransportModel transport) {
    _selectedTransport = transport;
    notifyListeners();
  }

  // Seleccionar estación
  void selectStation(StationModel station) {
    _selectedStation = station;
    loadStationTransports(station.id);
    loadStationAvailability(station.id);
    notifyListeners();
  }

  // Agregar nueva estación
  Future<bool> addStation(StationModel station) async {
    _setLoading(true);
    try {
      await _databaseService.addStation(station);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al agregar estación: $e';
      _setLoading(false);
      return false;
    }
  }

  // Agregar nuevo transporte
  Future<bool> addTransport(TransportModel transport) async {
    _setLoading(true);
    try {
      await _databaseService.addTransport(transport);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al agregar transporte: $e';
      _setLoading(false);
      return false;
    }
  }

  // Obtener transportes disponibles en una estación
  List<TransportModel> getAvailableTransports(String stationId) {
    return _stationTransports[stationId]?.where((t) => t.isAvailable).toList() ?? [];
  }

  // Obtener resumen de inventario por estación
  Map<String, Map<TransportType, int>> getStationInventorySummary() {
    Map<String, Map<TransportType, int>> summary = {};
    
    for (var station in _stations) {
      Map<TransportType, int> stationInventory = {
        TransportType.bicycle: 0,
        TransportType.skateboard: 0,
        TransportType.scooter: 0,
      };
      
      final stationTransports = _stationTransports[station.id] ?? [];
      for (var transport in stationTransports) {
        if (transport.isAvailable) {
          stationInventory[transport.type] = (stationInventory[transport.type] ?? 0) + 1;
        }
      }
      
      summary[station.id] = stationInventory;
    }
    
    return summary;
  }

  // Verificar si hay movimiento de inventario entre estaciones
  bool hasInventoryMovement(String fromStationId, String toStationId) {
    return fromStationId != toStationId;
  }

  // Limpiar selecciones
  void clearSelections() {
    _selectedTransport = null;
    _selectedStation = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
