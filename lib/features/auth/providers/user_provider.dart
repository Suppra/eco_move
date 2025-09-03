import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../loans/models/loan_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  UserModel? _user;
  List<LoanModel> _activeLoans = [];
  List<LoanModel> _loanHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  List<LoanModel> get activeLoans => _activeLoans;
  List<LoanModel> get loanHistory => _loanHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Inicializar usuario actual
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      final currentUser = await _authService.getCurrentUserOnce();
      if (currentUser != null) {
        _user = currentUser;
        await _loadUserLoans();
      }
      _error = null;
    } catch (e) {
      _error = 'Error al cargar usuario: $e';
    }
    _setLoading(false);
  }

  // Cargar préstamos del usuario
  Future<void> _loadUserLoans() async {
    if (_user == null) return;
    
    try {
      // Escuchar préstamos activos
      _databaseService.getActiveLoans(_user!.id).listen((loans) {
        _activeLoans = loans;
        notifyListeners();
      });

      // Cargar historial
      _databaseService.getUserLoans(_user!.id).listen((loans) {
        _loanHistory = loans.where((loan) => loan.endTime != null).toList();
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al cargar préstamos: $e';
      notifyListeners();
    }
  }

  // Autenticar usuario
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _user = user;
        await _loadUserLoans();
        _error = null;
        _setLoading(false);
        return true;
      }
      _error = 'Credenciales incorrectas';
    } catch (e) {
      _error = 'Error al iniciar sesión: $e';
    }
    _setLoading(false);
    return false;
  }

  // Registrar usuario
  Future<bool> signUp(String email, String password, String name, String document) async {
    _setLoading(true);
    try {
      final user = await _authService.createUserWithEmailAndPassword(email, password, name, document);
      if (user != null) {
        _user = user;
        _error = null;
        _setLoading(false);
        return true;
      }
      _error = 'Error al crear cuenta';
    } catch (e) {
      _error = 'Error al registrarse: $e';
    }
    _setLoading(false);
    return false;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _activeLoans = [];
    _loanHistory = [];
    _error = null;
    notifyListeners();
  }

  // Tomar transporte
  Future<bool> borrowTransport(String transportId, String stationId) async {
    if (_user == null) return false;
    
    _setLoading(true);
    try {
      await _databaseService.createLoan(
        userId: _user!.id,
        transportId: transportId,
        startStationId: stationId,
      );
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al tomar transporte: $e';
      _setLoading(false);
      return false;
    }
  }

  // Devolver transporte
  Future<bool> returnTransport(String loanId, String endStationId) async {
    _setLoading(true);
    try {
      await _databaseService.completeLoan(
        loanId: loanId,
        endStationId: endStationId,
      );
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Error al devolver transporte: $e';
      _setLoading(false);
      return false;
    }
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