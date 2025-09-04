import 'package:flutter/material.dart';
import 'dart:async';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../loans/models/loan_model.dart';
import '../../auth/models/user_model.dart';
import '../../loans/screens/loans_screen.dart';
import '../../stations/screens/stations_screen.dart';
import '../../statistics/screens/statistics_screen.dart';
import '../../../shared/widgets/menu_home.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
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
        setState(() {
          _cachedActiveLoan = activeLoan;
        });
      }
    });
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
        body: const Center(child: CircularProgressIndicator()),
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
                  content: const Text(
                    '¿Estás seguro de que quieres cerrar sesión?',
                  ),
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
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.eco, color: Colors.green, size: 32),
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
                          Icon(
                            Icons.directions_bike,
                            color: Colors.orange.shade700,
                          ),
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
                      Text(
                        'Inicio: ${_formatDateTime(_cachedActiveLoan!.startTime)}',
                      ),
                      ElapsedTimeWidget(
                        startTime: _cachedActiveLoan!.startTime,
                        style: const TextStyle(fontSize: 14),
                      ),
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
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 48,
                      ),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  1, // Navigate to Stations tab
                ),
                _buildActionCard(
                  'Mis Préstamos',
                  'Historial y activos',
                  Icons.history,
                  Colors.orange,
                  2, // Navigate to Loans tab
                ),
                _buildActionCard(
                  'Estadísticas',
                  'Tu uso ecológico',
                  Icons.analytics,
                  Colors.purple,
                  3, // Navigate to Statistics tab
                ),
                _buildActionCard(
                  'Información',
                  'Tarifas y ayuda',
                  Icons.info_outline,
                  Colors.teal,
                  0, // Navigate to Home tab
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int targetIndex, // Pass the target tab index
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MenuHome(initialIndex: targetIndex),
            ),
            (route) => false, // Remove all previous routes
          );
        },
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
            Text(
              'Tarifas por minuto:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
}

// Widget optimizado para mostrar tiempo transcurrido sin rebuilds innecesarios
class ElapsedTimeWidget extends StatefulWidget {
  final DateTime startTime;
  final TextStyle? style;

  const ElapsedTimeWidget({Key? key, required this.startTime, this.style})
    : super(key: key);

  @override
  State<ElapsedTimeWidget> createState() => _ElapsedTimeWidgetState();
}

class _ElapsedTimeWidgetState extends State<ElapsedTimeWidget> {
  late Timer _timer;
  String _timeText = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (mounted) {
      final elapsed = DateTime.now().difference(widget.startTime);
      final hours = elapsed.inHours;
      final minutes = elapsed.inMinutes % 60;
      final seconds = elapsed.inSeconds % 60;

      final newTimeText = hours > 0
          ? '${hours}h ${minutes}m ${seconds}s'
          : minutes > 0
          ? '${minutes}m ${seconds}s'
          : '${seconds}s';

      if (_timeText != newTimeText) {
        setState(() {
          _timeText = newTimeText;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Tiempo: $_timeText', style: widget.style);
  }
}
 