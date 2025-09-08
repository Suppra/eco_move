import 'package:flutter/material.dart';
import 'dart:io';
import '../models/transport_model.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../utils/validators.dart';

class AddTransportScreen extends StatefulWidget {
  final String stationId;

  const AddTransportScreen({Key? key, required this.stationId}) : super(key: key);

  @override
  State<AddTransportScreen> createState() => _AddTransportScreenState();
}

class _AddTransportScreenState extends State<AddTransportScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  TransportType _selectedType = TransportType.bicycle;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Mostrar opciones para seleccionar imagen
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de Galería'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.pickImageFromGallery();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar Foto'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.takePhoto();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Quitar Imagen'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // Guardar transporte
  Future<void> _saveTransport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final transportId = DateTime.now().millisecondsSinceEpoch.toString();
      String? imageUrl;

      // Subir imagen si fue seleccionada
      if (_selectedImage != null) {
        imageUrl = await ImageService.uploadTransportImage(_selectedImage!, transportId);
        if (imageUrl == null) {
          throw Exception('Error al subir la imagen');
        }
      }

      // Crear características básicas según el tipo
      Map<String, dynamic> characteristics = {};
      switch (_selectedType) {
        case TransportType.bicycle:
          characteristics = {
            'velocidadMaxima': 25,
            'peso': 15.0,
            'capacidadCarga': 20.0,
          };
          break;
        case TransportType.scooter:
          characteristics = {
            'velocidadMaxima': 35,
            'autonomia': 40,
            'peso': 25.0,
            'nivelBateria': 100,
          };
          break;
        case TransportType.skateboard:
          characteristics = {
            'velocidadMaxima': 20,
            'peso': 5.0,
            'capacidadCarga': 100.0,
          };
          break;
      }

      final transport = TransportModel(
        id: transportId,
        type: _selectedType,
        stationId: widget.stationId,
        isAvailable: true,
        name: _nameController.text.trim(),
        characteristics: characteristics,
        imageUrl: imageUrl,
      );

      await _databaseService.addTransport(transport);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transporte agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar transporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Transporte'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selección de imagen
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toca para agregar una foto del transporte',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Nombre del transporte
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre/ID del Transporte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'Ej: Bicicleta Verde #001',
                ),
                validator: Validators.validateTransportName,
              ),
              const SizedBox(height: 16),

              // Tipo de transporte
              DropdownButtonFormField<TransportType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transporte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions),
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
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Información sobre características
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Características automáticas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Las características técnicas se asignarán automáticamente según el tipo de transporte seleccionado.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botón para guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Guardando...'),
                        ],
                      )
                    : const Text(
                        'Agregar Transporte',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
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
