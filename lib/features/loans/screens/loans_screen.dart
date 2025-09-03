import 'package:flutter/material.dart';
import 'dart:async';
import '../models/loan_model.dart';
import '../../stations/models/transport_model.dart';
import '../../stations/models/station_model.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para devolver transporte
  Future<void> _returnTransport(LoanModel loan) async {
    try {
      // Mostrar diálogo para seleccionar estación de devolución
      final stations = await _databaseService.stations.first;
      if (stations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay estaciones disponibles para devolución'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final selectedStation = await showDialog<StationModel>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Estación de Devolución'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(station.name),
                  subtitle: Text(station.location),
                  onTap: () => Navigator.pop(context, station),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (selectedStation != null) {
        final cost = await _databaseService.completeLoan(
          loanId: loan.id,
          endStationId: selectedStation.id,
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Transporte Devuelto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text('Costo total: \$${cost.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Pago en efectivo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Devuelto en: ${selectedStation.name}'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al devolver transporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Préstamos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Activos', icon: Icon(Icons.pending)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _authService.getCurrentUserOnce(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userSnapshot.data;
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Usuario no autenticado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab de préstamos activos
              _buildActiveLoansTab(user.id),
              // Tab de historial
              _buildHistoryTab(user.id),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveLoansTab(String userId) {
    return StreamBuilder<List<LoanModel>>(
      stream: _databaseService.getActiveLoans(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final activeLoans = snapshot.data ?? [];

        if (activeLoans.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bike_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes préstamos activos',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Ve a una estación para tomar un transporte',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeLoans.length,
          itemBuilder: (context, index) {
            final loan = activeLoans[index];
            return _buildActiveLoanCard(loan);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(String userId) {
    return StreamBuilder<List<LoanModel>>(
      stream: _databaseService.getUserLoans(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allLoans = snapshot.data ?? [];
        final completedLoans = allLoans.where((loan) => loan.endTime != null).toList();

        if (completedLoans.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes préstamos en el historial',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedLoans.length,
          itemBuilder: (context, index) {
            final loan = completedLoans[index];
            return _buildHistoryLoanCard(loan);
          },
        );
      },
    );
  }

  Widget _buildActiveLoanCard(LoanModel loan) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_bike, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRÉSTAMO ACTIVO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                      FutureBuilder<TransportModel?>(
                        future: _databaseService.getTransport(loan.transportId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final transport = snapshot.data!;
                            return Text(
                              transport.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          }
                          return const Text('Cargando...');
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EN USO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Inicio: ${_formatDateTime(loan.startTime)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FutureBuilder<StationModel?>(
              future: _databaseService.getStation(loan.startStationId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Desde: ${snapshot.data!.name}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElapsedTimeWidget(startTime: loan.startTime),
                ),
                ElevatedButton(
                  onPressed: () => _returnTransport(loan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Devolver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryLoanCard(LoanModel loan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<TransportModel?>(
                    future: _databaseService.getTransport(loan.transportId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final transport = snapshot.data!;
                        return Text(
                          transport.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }
                      return const Text('Cargando...');
                    },
                  ),
                ),
                Text(
                  '\$${loan.cost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDateTime(loan.startTime)} - ${_formatDateTime(loan.endTime!)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Duración: ${_getDuration(loan.startTime, loan.endTime!)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<StationModel?>(
                    future: _databaseService.getStation(loan.startStationId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Desde: ${snapshot.data!.name}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                if (loan.endStationId != null)
                  Expanded(
                    child: FutureBuilder<StationModel?>(
                      future: _databaseService.getStation(loan.endStationId!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            'Hasta: ${snapshot.data!.name}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

// Widget separado para mostrar tiempo transcurrido sin afectar el resto de la pantalla
class ElapsedTimeWidget extends StatefulWidget {
  final DateTime startTime;

  const ElapsedTimeWidget({Key? key, required this.startTime}) : super(key: key);

  @override
  State<ElapsedTimeWidget> createState() => _ElapsedTimeWidgetState();
}

class _ElapsedTimeWidgetState extends State<ElapsedTimeWidget> {
  Timer? _timer;
  String _elapsedTime = '';

  @override
  void initState() {
    super.initState();
    _updateElapsedTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateElapsedTime();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsedTime() {
    final elapsed = DateTime.now().difference(widget.startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;
    
    String newTime;
    if (hours > 0) {
      newTime = '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      newTime = '${minutes}m ${seconds}s';
    } else {
      newTime = '${seconds}s';
    }
    
    if (newTime != _elapsedTime) {
      setState(() {
        _elapsedTime = newTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tiempo transcurrido: $_elapsedTime',
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}
