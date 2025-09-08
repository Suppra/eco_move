import 'package:flutter/material.dart';
import '../models/transport_model.dart';

class TransportCharacteristicsWidget extends StatelessWidget {
  final TransportModel transport;

  const TransportCharacteristicsWidget({
    Key? key,
    required this.transport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characteristics = transport.characteristics ?? 
        TransportModel.getDefaultCharacteristics(transport.type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTransportIcon(transport.type),
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Características del ${_getTransportName(transport.type)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildCharacteristicsList(characteristics),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCharacteristicsList(Map<String, dynamic> characteristics) {
    return characteristics.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getCharacteristicIcon(entry.key),
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_getCharacteristicLabel(entry.key)}: ${_formatValue(entry.key, entry.value)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }).toList();
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
        return 'Scooter Eléctrico';
      case TransportType.skateboard:
        return 'Skateboard';
    }
  }

  IconData _getCharacteristicIcon(String key) {
    switch (key) {
      case 'bateria_porcentaje':
      case 'autonomia_km':
      case 'tiempo_carga_horas':
        return Icons.battery_full;
      case 'velocidad_max_kmh':
        return Icons.speed;
      case 'peso_kg':
        return Icons.fitness_center;
      case 'marcha':
      case 'frenos':
        return Icons.settings;
      case 'material':
      case 'material_tabla':
        return Icons.category;
      case 'tamano_rueda':
      case 'longitud_cm':
      case 'ancho_cm':
        return Icons.straighten;
      case 'tipo_ruedas':
        return Icons.circle;
      default:
        return Icons.info;
    }
  }

  String _getCharacteristicLabel(String key) {
    switch (key) {
      case 'bateria_porcentaje':
        return 'Batería';
      case 'autonomia_km':
        return 'Autonomía';
      case 'velocidad_max_kmh':
        return 'Velocidad máxima';
      case 'tiempo_carga_horas':
        return 'Tiempo de carga';
      case 'peso_kg':
        return 'Peso';
      case 'marcha':
        return 'Marchas';
      case 'material':
        return 'Material';
      case 'frenos':
        return 'Frenos';
      case 'tamano_rueda':
        return 'Tamaño de rueda';
      case 'longitud_cm':
        return 'Longitud';
      case 'ancho_cm':
        return 'Ancho';
      case 'material_tabla':
        return 'Material de la tabla';
      case 'tipo_ruedas':
        return 'Tipo de ruedas';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatValue(String key, dynamic value) {
    switch (key) {
      case 'bateria_porcentaje':
        return '${value}%';
      case 'autonomia_km':
        return '${value} km';
      case 'velocidad_max_kmh':
        return '${value} km/h';
      case 'tiempo_carga_horas':
        return '${value} horas';
      case 'peso_kg':
        return '${value} kg';
      case 'longitud_cm':
      case 'ancho_cm':
        return '${value} cm';
      default:
        return value.toString();
    }
  }
}
