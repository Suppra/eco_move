import 'package:flutter/material.dart';
import '../models/station_model.dart';
import '../models/transport_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/transport_characteristics_widget.dart';
import 'add_transport_screen.dart';

class StationDetailScreen extends StatefulWidget {
  final StationModel station;

  const StationDetailScreen({Key? key, required this.station}) : super(key: key);

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  // Cache para transportes y disponibilidad
  List<TransportModel>? _cachedTransports;
  Map<TransportType, int>? _cachedAvailability;
  late Stream<List<TransportModel>> _transportStream;
  
  // Filtros
  TransportType? _selectedTypeFilter;
  
  @override
  void initState() {
    super.initState();
    _transportStream = _databaseService.getTransportsByStation(widget.station.id);
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      final availability = await _databaseService.getStationAvailability(widget.station.id);
      if (mounted) {
        setState(() {
          _cachedAvailability = availability;
        });
      }
    } catch (e) {
      print('Error loading station availability: $e');
    }
  }

  // Método para agregar nuevo transporte a la estación
  void _showAddTransportDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransportScreen(stationId: widget.station.id),
      ),
    );
  }

  // Método para realizar préstamo
  Future<void> _borrowTransport(TransportModel transport) async {
    try {
      // Usar el método cached para evitar streams excesivos
      final currentUser = await _authService.getCurrentUserOnce();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe iniciar sesión para tomar un transporte'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Usuario autenticado: ${currentUser.id}');

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

      print('Creando préstamo para usuario: ${currentUser.id}, transporte: ${transport.id}');

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
      print('Error detallado al tomar transporte: $e');
      
      String errorMessage = 'Error al tomar el transporte';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Sin permisos para realizar esta operación. Verifique las reglas de Firestore.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifique su internet.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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
                    // Mostrar disponibilidad por tipo (usar cache cuando esté disponible)
                    _cachedAvailability != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAvailabilityItem(
                                TransportType.bicycle,
                                _cachedAvailability![TransportType.bicycle] ?? 0,
                              ),
                              _buildAvailabilityItem(
                                TransportType.scooter,
                                _cachedAvailability![TransportType.scooter] ?? 0,
                              ),
                              _buildAvailabilityItem(
                                TransportType.skateboard,
                                _cachedAvailability![TransportType.skateboard] ?? 0,
                              ),
                            ],
                          )
                        : FutureBuilder<Map<TransportType, int>>(
                            future: _databaseService.getStationAvailability(widget.station.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final availability = snapshot.data!;
                                // Actualizar cache
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _cachedAvailability = availability;
                                    });
                                  }
                                });
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildAvailabilityItem(
                                      TransportType.bicycle,
                                      availability[TransportType.bicycle] ?? 0,
                                    ),
                                    _buildAvailabilityItem(
                                      TransportType.scooter,
                                      availability[TransportType.scooter] ?? 0,
                                    ),
                                    _buildAvailabilityItem(
                                      TransportType.skateboard,
                                      availability[TransportType.skateboard] ?? 0,
                                    ),
                                  ],
                                );
                              }
                              return const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              );
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
            
            // Filtros de transporte
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Filtros por tipo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', null, true),
                        const SizedBox(width: 8),
                        _buildFilterChip('🚲 Bicicletas', TransportType.bicycle, true),
                        const SizedBox(width: 8),
                        _buildFilterChip('🛴 Scooters', TransportType.scooter, true),
                        const SizedBox(width: 8),
                        _buildFilterChip('🛹 Patinetas', TransportType.skateboard, true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<TransportModel>>(
                stream: _transportStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _cachedTransports == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Usar datos del stream si están disponibles, sino usar cache
                  final allTransports = snapshot.data ?? _cachedTransports ?? [];
                  
                  // Aplicar filtros
                  final transports = _applyFilters(allTransports);
                  
                  // Actualizar cache cuando lleguen nuevos datos
                  if (snapshot.hasData && snapshot.data != _cachedTransports) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _cachedTransports = snapshot.data;
                          // También actualizar la disponibilidad cuando cambien los transportes
                          _loadInitialData();
                        });
                      }
                    });
                  }

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
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: transport.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      transport.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return CircleAvatar(
                                          backgroundColor: transport.isAvailable 
                                              ? Colors.green 
                                              : Colors.grey,
                                          child: Icon(
                                            _getTransportIcon(transport.type),
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: transport.isAvailable 
                                        ? Colors.green 
                                        : Colors.grey,
                                    child: Icon(
                                      _getTransportIcon(transport.type),
                                      color: Colors.white,
                                    ),
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
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Botón para ver características
                                IconButton(
                                  onPressed: () => _showTransportDetails(transport),
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: 'Ver características',
                                  iconSize: 20,
                                ),
                                const SizedBox(width: 4),
                                // Botón para tomar o estado
                                if (transport.isAvailable)
                                  ElevatedButton(
                                    onPressed: () => _borrowTransport(transport),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: const Size(60, 32),
                                    ),
                                    child: const Text('Tomar', style: TextStyle(fontSize: 12)),
                                  )
                                else
                                  const Chip(
                                    label: Text('En uso', style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.orange,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
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

  // Método para mostrar características del transporte
  void _showTransportDetails(TransportModel transport) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transport.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TransportCharacteristicsWidget(transport: transport),
            ],
          ),
        ),
      ),
    );
  }

  // Construir chips de filtro por tipo
  Widget _buildFilterChip(String label, TransportType? type, bool isTypeFilter) {
    final isSelected = isTypeFilter ? _selectedTypeFilter == type : false;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = selected ? type : null;
        });
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
      backgroundColor: Colors.grey.shade100,
    );
  }

  // Construir chips de filtro por estado
  // Aplicar filtros a la lista de transportes
  List<TransportModel> _applyFilters(List<TransportModel> transports) {
    List<TransportModel> filtered = transports;

    // Filtrar por tipo
    if (_selectedTypeFilter != null) {
      filtered = filtered.where((transport) => transport.type == _selectedTypeFilter).toList();
    }

    return filtered;
  }
}
