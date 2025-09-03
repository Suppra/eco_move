import 'package:flutter/material.dart';
import '../providers/transport_provider.dart';
import '../providers/user_provider.dart';
import '../models/transport_model.dart';
import '../models/station_model.dart';

class TransportController {
  final TransportProvider transportProvider;
  final UserProvider userProvider;

  TransportController(this.transportProvider, this.userProvider);

  // Manejar selección de estación
  void handleStationSelection(StationModel station) {
    transportProvider.selectStation(station);
  }

  // Manejar tomar transporte
  Future<void> handleBorrowTransport(
    BuildContext context,
    TransportModel transport,
    String stationId,
  ) async {
    if (!userProvider.isAuthenticated) {
      _showError(context, 'Debe iniciar sesión para tomar un transporte');
      return;
    }

    if (userProvider.activeLoans.isNotEmpty) {
      _showError(context, 'Ya tienes un préstamo activo. Devuelve el transporte primero.');
      return;
    }

    final success = await userProvider.borrowTransport(transport.id, stationId);
    
    if (success) {
      _showSuccess(context, 'Transporte tomado exitosamente');
    } else {
      _showError(context, userProvider.error ?? 'Error al tomar transporte');
    }
  }

  // Manejar devolución de transporte
  Future<void> handleReturnTransport(
    BuildContext context,
    String loanId,
    String endStationId,
  ) async {
    final success = await userProvider.returnTransport(loanId, endStationId);
    
    if (success) {
      _showSuccess(context, 'Transporte devuelto exitosamente');
    } else {
      _showError(context, userProvider.error ?? 'Error al devolver transporte');
    }
  }

  // Manejar agregar nueva estación
  Future<void> handleAddStation(
    BuildContext context,
    String name,
    String location,
    int capacity,
  ) async {
    final station = StationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      location: location,
      capacity: capacity,
    );

    final success = await transportProvider.addStation(station);
    
    if (success) {
      _showSuccess(context, 'Estación agregada exitosamente');
    } else {
      _showError(context, transportProvider.error ?? 'Error al agregar estación');
    }
  }

  // Manejar agregar nuevo transporte
  Future<void> handleAddTransport(
    BuildContext context,
    String name,
    TransportType type,
    String stationId,
  ) async {
    final transport = TransportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      stationId: stationId,
      isAvailable: true,
    );

    final success = await transportProvider.addTransport(transport);
    
    if (success) {
      _showSuccess(context, 'Transporte agregado exitosamente');
    } else {
      _showError(context, transportProvider.error ?? 'Error al agregar transporte');
    }
  }

  // Obtener estadísticas
  Map<String, dynamic> getStatistics() {
    final totalStations = transportProvider.stations.length;
    final totalTransports = transportProvider.transports.length;
    final availableTransports = transportProvider.transports.where((t) => t.isAvailable).length;
    final activeLoans = userProvider.activeLoans.length;
    
    return {
      'totalStations': totalStations,
      'totalTransports': totalTransports,
      'availableTransports': availableTransports,
      'activeLoans': activeLoans,
    };
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
