import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';
import 'loans_screen.dart';
import 'stations_screen.dart';
import 'statistics_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  Timer? _timer;
  UserModel? _cachedUser;
  LoanModel? _cachedActiveLoan;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // Usar el método cached para evitar queries excesivas a Firestore
      final user = await _authService.getCurrentUserOnce();
      if (user != null && mounted) {
        setState(() {
          _cachedUser = user;
        });
        _startListeningForActiveLoans();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _startListeningForActiveLoans() {
    if (_cachedUser == null) return;
    
    _databaseService.getActiveLoans(_cachedUser!.id).listen((loans) {
      if (mounted) {
        final activeLoan = loans.isNotEmpty ? loans.first : null;
        final hadLoan = _cachedActiveLoan != null;
        final hasLoan = activeLoan != null;
        
        setState(() {
          _cachedActiveLoan = activeLoan;
        });
        
        if (hasLoan && !hadLoan) {
          _startTimer();
        } else if (!hasLoan && hadLoan) {
          _stopTimer();
        }
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _cachedActiveLoan != null) {
        setState(() {
          // Solo actualizar el tiempo
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EcoMove'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = _cachedUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoMove'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
              
              if (shouldLogout == true) {
                await _authService.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 30,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${user.name}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Bienvenido a EcoMove',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estado del préstamo activo
            if (_cachedActiveLoan != null)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_bike, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'PRÉSTAMO ACTIVO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Inicio: ${_formatDateTime(_cachedActiveLoan!.startTime)}'),
                      Text('Tiempo: ${_getElapsedTime(_cachedActiveLoan!.startTime)}'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoansScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Ver Detalles'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Sin préstamos activos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('¡Estás listo para tomar un transporte!'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Acciones rápidas
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de acciones
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  'Estaciones',
                  'Ver disponibilidad',
                  Icons.location_on,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StationsScreen()),
                  ),
                ),
                _buildActionCard(
                  'Mis Préstamos',
                  'Historial y activos',
                  Icons.history,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoansScreen()),
                  ),
                ),
                _buildActionCard(
                  'Estadísticas',
                  'Tu uso ecológico',
                  Icons.analytics,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  ),
                ),
                _buildActionCard(
                  'Información',
                  'Tarifas y ayuda',
                  Icons.info_outline,
                  Colors.teal,
                  () => _showInfoDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Tarifas'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarifas por minuto:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Bicicleta: \$1.00 base + \$0.10/min'),
            Text('• Patineta: \$1.00 base + \$0.15/min'),
            Text('• Scooter: \$1.00 base + \$0.20/min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getElapsedTime(DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
