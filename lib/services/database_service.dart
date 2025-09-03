import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/stations/models/transport_model.dart';
import '../features/stations/models/station_model.dart';
import '../features/loans/models/loan_model.dart';
import '../features/auth/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Registro de usuarios (datos básicos: nombre, correo, documento)
  Future<void> registerUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // 2. Gestión de estaciones
  Stream<List<StationModel>> get stations {
    return _firestore
        .collection('stations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addStation(StationModel station) async {
    await _firestore.collection('stations').doc(station.id).set(station.toMap());
  }

  Future<void> updateStation(StationModel station) async {
    await _firestore.collection('stations').doc(station.id).update(station.toMap());
  }

  Future<void> deleteStation(String stationId) async {
    await _firestore.collection('stations').doc(stationId).delete();
  }

  Future<StationModel?> getStation(String stationId) async {
    final doc = await _firestore.collection('stations').doc(stationId).get();
    if (doc.exists) {
      return StationModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // 3. Gestión de transporte disponible (bicicletas y patinetas)
  Stream<List<TransportModel>> get transports {
    return _firestore
        .collection('transports')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addTransport(TransportModel transport) async {
    await _firestore.collection('transports').doc(transport.id).set(transport.toMap());
  }

  Future<void> updateTransport(TransportModel transport) async {
    await _firestore.collection('transports').doc(transport.id).update(transport.toMap());
  }

  Future<void> deleteTransport(String transportId) async {
    await _firestore.collection('transports').doc(transportId).delete();
  }

  Future<TransportModel?> getTransport(String transportId) async {
    final doc = await _firestore.collection('transports').doc(transportId).get();
    if (doc.exists) {
      return TransportModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // 4. Consulta de disponibilidad de transporte en una estación
  Stream<List<TransportModel>> getAvailableTransportsByStation(String stationId) {
    return _firestore
        .collection('transports')
        .where('stationId', isEqualTo: stationId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<TransportModel>> getTransportsByStation(String stationId) {
    return _firestore
        .collection('transports')
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Map<TransportType, int>> getStationAvailability(String stationId) async {
    final snapshot = await _firestore
        .collection('transports')
        .where('stationId', isEqualTo: stationId)
        .where('isAvailable', isEqualTo: true)
        .get();

    Map<TransportType, int> availability = {
      TransportType.bicycle: 0,
      TransportType.skateboard: 0,
      TransportType.scooter: 0,
    };

    for (var doc in snapshot.docs) {
      final transport = TransportModel.fromMap(doc.data(), doc.id);
      availability[transport.type] = (availability[transport.type] ?? 0) + 1;
    }

    return availability;
  }

  // 5. Realizar un préstamo de transporte
  Future<String> createLoan({
    required String userId,
    required String transportId,
    required String startStationId,
  }) async {
    final loanId = _firestore.collection('loans').doc().id;
    final loan = LoanModel(
      id: loanId,
      userId: userId,
      transportId: transportId,
      startTime: DateTime.now(),
      startStationId: startStationId,
      cost: 0.0, // Se calculará al finalizar
    );

    // Crear el préstamo
    await _firestore.collection('loans').doc(loanId).set(loan.toMap());
    
    // Marcar el transporte como no disponible
    await updateTransportAvailability(transportId, false, startStationId);

    return loanId;
  }

  Future<void> updateTransportAvailability(String transportId, bool isAvailable, String stationId) async {
    await _firestore.collection('transports').doc(transportId).update({
      'isAvailable': isAvailable,
      'stationId': stationId,
    });
  }

  // 6. Calcular el costo del préstamo (según tipo de transporte y duración)
  double calculateBasicCost(TransportType type, int minutes) {
    switch (type) {
      case TransportType.bicycle:
        return minutes * 0.1; // $0.1 por minuto
      case TransportType.skateboard:
        return minutes * 0.15; // $0.15 por minuto
      case TransportType.scooter:
        return minutes * 0.2; // $0.2 por minuto
    }
  }

  double calculateCost(TransportType type, int minutes) {
    double baseRate = 1.0; // Tarifa base
    double perMinuteRate;
    
    switch (type) {
      case TransportType.bicycle:
        perMinuteRate = 0.1;
        break;
      case TransportType.skateboard:
        perMinuteRate = 0.15;
        break;
      case TransportType.scooter:
        perMinuteRate = 0.2;
        break;
    }
    
    return baseRate + (minutes * perMinuteRate);
  }

  // 7. Devolución de transporte y actualizar disponibilidad
  Future<double> completeLoan({
    required String loanId,
    required String endStationId,
  }) async {
    final loanDoc = await _firestore.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) {
      throw Exception('Préstamo no encontrado');
    }

    final loan = LoanModel.fromMap(loanDoc.data()!, loanId);
    final endTime = DateTime.now();
    final duration = endTime.difference(loan.startTime);
    final minutes = duration.inMinutes;

    // Obtener el tipo de transporte para calcular el costo
    final transport = await getTransport(loan.transportId);
    if (transport == null) {
      throw Exception('Transporte no encontrado');
    }

    final cost = calculateCost(transport.type, minutes);

    // Actualizar el préstamo con la información de devolución
    final updatedLoan = LoanModel(
      id: loan.id,
      userId: loan.userId,
      transportId: loan.transportId,
      startTime: loan.startTime,
      endTime: endTime,
      startStationId: loan.startStationId,
      endStationId: endStationId,
      cost: cost,
    );

    await _firestore.collection('loans').doc(loanId).update(updatedLoan.toMap());
    
    // Marcar el transporte como disponible en la nueva estación
    await updateTransportAvailability(loan.transportId, true, endStationId);

    return cost;
  }

  // 8. Historial de préstamos por usuario
  Stream<List<LoanModel>> getUserLoans(String userId) {
    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          var loans = snapshot.docs
              .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
              .toList();
          // Ordenar en el cliente para evitar índices complejos
          loans.sort((a, b) => b.startTime.compareTo(a.startTime));
          return loans;
        });
  }

  Future<List<LoanModel>> getUserLoansHistory(String userId) async {
    final snapshot = await _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .get();

    var loans = snapshot.docs
        .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
        .toList();
    
    // Ordenar en el cliente y filtrar solo los completados
    loans.sort((a, b) => b.startTime.compareTo(a.startTime));
    return loans.where((loan) => loan.endTime != null).toList();
  }

  // Préstamos activos (sin finalizar) - simplificado para evitar índices complejos
  Stream<List<LoanModel>> getActiveLoans(String userId) {
    return _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Filtrar en el cliente los préstamos activos
          return snapshot.docs
              .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
              .where((loan) => loan.endTime == null)
              .toList();
        });
  }

  Future<LoanModel?> getActiveLoan(String userId) async {
    final snapshot = await _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .get();

    // Filtrar en el cliente para obtener el préstamo activo
    final activeLoans = snapshot.docs
        .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
        .where((loan) => loan.endTime == null)
        .toList();

    return activeLoans.isNotEmpty ? activeLoans.first : null;
  }

  // Gestión general de préstamos
  Future<void> addLoan(LoanModel loan) async {
    await _firestore.collection('loans').doc(loan.id).set(loan.toMap());
  }

  Future<void> updateLoan(LoanModel loan) async {
    await _firestore.collection('loans').doc(loan.id).update(loan.toMap());
  }

  // Estadísticas
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final loansSnapshot = await _firestore
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .where('endTime', isNotEqualTo: null)
        .get();

    int totalTrips = loansSnapshot.docs.length;
    double totalCost = 0.0;
    int totalMinutes = 0;

    for (var doc in loansSnapshot.docs) {
      final loan = LoanModel.fromMap(doc.data(), doc.id);
      totalCost += loan.cost;
      if (loan.endTime != null) {
        totalMinutes += loan.endTime!.difference(loan.startTime).inMinutes;
      }
    }

    return {
      'totalTrips': totalTrips,
      'totalCost': totalCost,
      'totalMinutes': totalMinutes,
      'averageTripDuration': totalTrips > 0 ? totalMinutes / totalTrips : 0,
      'averageCost': totalTrips > 0 ? totalCost / totalTrips : 0,
    };
  }
}