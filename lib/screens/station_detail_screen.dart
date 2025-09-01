import 'package:flutter/material.dart';
import '../models/station_model.dart';
import '../models/transport_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class StationDetailScreen extends StatefulWidget {
  final StationModel station;

  const StationDetailScreen({Key? key, required this.station}) : super(key: key);

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  // Método para agregar nuevo transporte a la estación
  void _showAddTransportDialog() {
    final nameController = TextEditingController();
    TransportType selectedType = TransportType.bicycle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Nuevo Transporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre/ID del Transporte',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransportType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transporte',
                  border: OutlineInputBorder(),
                ),
                items: TransportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTransportIcon(type)),
                        const SizedBox(width: 8),
                        Text(_getTransportName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final transportId = DateTime.now().millisecondsSinceEpoch.toString();
                  final transport = TransportModel(
                    id: transportId,
                    type: selectedType,
                    stationId: widget.station.id,
                    isAvailable: true,
                    name: nameController.text,
                  );
                  
                  await _databaseService.addTransport(transport);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transporte agregado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para realizar préstamo
  Future<void> _borrowTransport(TransportModel transport) async {
    try {
      final currentUser = await _authService.currentUser.first;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe iniciar sesión para tomar un transporte'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verificar si el usuario ya tiene un préstamo activo
      final activeLoan = await _databaseService.getActiveLoan(currentUser.id);
      if (activeLoan != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya tienes un préstamo activo. Devuelve el transporte primero.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _databaseService.createLoan(
        userId: currentUser.id,
        transportId: transport.id,
        startStationId: widget.station.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTransportName(transport.type)} tomado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar el transporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransportDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la estación
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.station.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.station.location,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.storage, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Capacidad: ${widget.station.capacity}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mostrar disponibilidad por tipo
                    FutureBuilder<Map<TransportType, int>>(
                      future: _databaseService.getStationAvailability(widget.station.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final availability = snapshot.data!;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAvailabilityItem(
                                TransportType.bicycle,
                                availability[TransportType.bicycle] ?? 0,
                              ),
                              _buildAvailabilityItem(
                                TransportType.skateboard,
                                availability[TransportType.skateboard] ?? 0,
                              ),
                              _buildAvailabilityItem(
                                TransportType.scooter,
                                availability[TransportType.scooter] ?? 0,
                              ),
                            ],
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Lista de transportes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transportes Disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddTransportDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<TransportModel>>(
                stream: _databaseService.getTransportsByStation(widget.station.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final transports = snapshot.data ?? [];

                  if (transports.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bike_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay transportes en esta estación',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar transportes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: transports.length,
                    itemBuilder: (context, index) {
                      final transport = transports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transport.isAvailable 
                                ? Colors.green 
                                : Colors.grey,
                            child: Icon(
                              _getTransportIcon(transport.type),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transport.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getTransportName(transport.type)),
                              Text(
                                transport.isAvailable ? 'Disponible' : 'En uso',
                                style: TextStyle(
                                  color: transport.isAvailable 
                                      ? Colors.green 
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: transport.isAvailable
                              ? ElevatedButton(
                                  onPressed: () => _borrowTransport(transport),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Tomar'),
                                )
                              : const Chip(
                                  label: Text('En uso'),
                                  backgroundColor: Colors.orange,
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityItem(TransportType type, int count) {
    return Column(
      children: [
        Icon(
          _getTransportIcon(type),
          color: count > 0 ? Colors.green : Colors.grey,
          size: 32,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: count > 0 ? Colors.green : Colors.grey,
          ),
        ),
        Text(
          _getTransportName(type),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  IconData _getTransportIcon(TransportType type) {
    switch (type) {
      case TransportType.bicycle:
        return Icons.directions_bike;
      case TransportType.scooter:
        return Icons.electric_scooter;
      case TransportType.skateboard:
        return Icons.skateboarding;
    }
  }

  String _getTransportName(TransportType type) {
    switch (type) {
      case TransportType.bicycle:
        return 'Bicicleta';
      case TransportType.scooter:
        return 'Scooter';
      case TransportType.skateboard:
        return 'Patineta';
    }
  }
}
