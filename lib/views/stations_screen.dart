import 'package:flutter/material.dart';
import '../models/station_model.dart';
import '../models/transport_model.dart';
import '../services/database_service.dart';
import 'station_detail_screen.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({Key? key}) : super(key: key);

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  // Método para agregar nueva estación
  void _showAddStationDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nueva Estación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Estación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidad',
                border: OutlineInputBorder(),
              ),
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
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  capacityController.text.isNotEmpty) {
                final stationId = DateTime.now().millisecondsSinceEpoch.toString();
                final station = StationModel(
                  id: stationId,
                  name: nameController.text,
                  location: locationController.text,
                  capacity: int.tryParse(capacityController.text) ?? 0,
                );
                
                await _databaseService.addStation(station);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estación agregada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estaciones'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStationDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<StationModel>>(
        stream: _databaseService.stations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stations = snapshot.data ?? [];

          if (stations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay estaciones registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca el botón + para agregar una estación',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    station.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.location),
                      const SizedBox(height: 4),
                      // Mostrar disponibilidad en tiempo real
                      FutureBuilder<Map<TransportType, int>>(
                        future: _databaseService.getStationAvailability(station.id),
                        builder: (context, availabilitySnapshot) {
                          if (availabilitySnapshot.hasData) {
                            final availability = availabilitySnapshot.data!;
                            return Text(
                              'Disponibles: ${availability[TransportType.bicycle]} 🚲 | '
                              '${availability[TransportType.skateboard]} 🛹 | '
                              '${availability[TransportType.scooter]} 🛴',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            );
                          }
                          return const Text('Cargando...', style: TextStyle(fontSize: 12));
                        },
                      ),
                    ],
                  ),
                  trailing: Text('Cap: ${station.capacity}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StationDetailScreen(station: station),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}