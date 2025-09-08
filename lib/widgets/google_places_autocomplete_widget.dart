import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PlacePrediction {
  final String description;
  final String placeId;
  final double? latitude;
  final double? longitude;

  PlacePrediction({
    required this.description,
    required this.placeId,
    this.latitude,
    this.longitude,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}

class GooglePlacesService {
  static const String apiKey = 'AIzaSyDZ93unHi2NVL1H-4aDSvuRmSxtGSQaa2o';
  
  static Future<List<PlacePrediction>> getAutocompletePredictions(String input) async {
    if (input.length < 2) return [];

    print('🔍 Buscando ubicaciones globales para: "$input"');

    try {
      // Usamos la nueva Places API (New) para autocompletar
      final String url = 'https://places.googleapis.com/v1/places:autocomplete';
      
      final Map<String, dynamic> requestBody = {
        'input': input,
        'languageCode': 'es',
        'regionCode': 'CO', // Colombia como región preferida pero permite global
        'includedPrimaryTypes': ['establishment', 'geocode'], // Incluye establecimientos y ubicaciones geocodificadas
        'includedRegionCodes': ['CO', 'US', 'MX', 'ES', 'AR', 'CL', 'PE', 'VE'], // Países principales
        'maxResults': 8
      };

      print('🌐 Consultando Places API (New): $url');
      print('📤 Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text'
        },
        body: json.encode(requestBody),
      );

      print('📡 Respuesta Places API: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📥 Respuesta completa: $data');
        
        if (data['suggestions'] != null) {
          final suggestions = data['suggestions'] as List;
          final predictions = suggestions
              .where((suggestion) => suggestion['placePrediction'] != null)
              .map((suggestion) {
                final placePrediction = suggestion['placePrediction'];
                return PlacePrediction(
                  description: placePrediction['text']['text'] ?? '',
                  placeId: placePrediction['placeId'] ?? '',
                );
              })
              .toList();
          
          print('✅ ${predictions.length} ubicaciones globales encontradas');
          return predictions;
        }
      } else {
        print('❌ Error en Places API: ${response.statusCode} - ${response.body}');
        // Fallback a geocoding si la nueva API falla
        return await _tryGeocodingSearch(input);
      }
    } catch (e) {
      print('❌ Error en Places API (New): $e');
      // Fallback a geocoding en caso de error
      return await _tryGeocodingSearch(input);
    }

    return [];
  }

  static Future<List<PlacePrediction>> _tryGeocodingSearch(String input) async {
    try {
      // Usamos la API de Geocoding para buscar direcciones globalmente
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(input)}'
          '&key=$apiKey'
          '&language=es'
          '&region=co'; // Colombia como región preferida

      print('🌐 Fallback - Consultando Geocoding API: $url');

      final response = await http.get(Uri.parse(url));
      print('� Respuesta Geocoding: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          final predictions = results.take(5).map((result) {
            final location = result['geometry']['location'];
            return PlacePrediction(
              description: result['formatted_address'],
              placeId: result['place_id'] ?? '',
              latitude: (location['lat'] as num).toDouble(),
              longitude: (location['lng'] as num).toDouble(),
            );
          }).toList();
          
          print('✅ ${predictions.length} resultados de geocoding encontrados');
          return predictions;
        } else {
          print('❌ Error en Geocoding: ${data['status']}');
        }
      }
    } catch (e) {
      print('❌ Error en geocoding search: $e');
    }

    return [];
  }

  static Future<Map<String, double>?> getPlaceCoordinates(String placeId) async {
    print('🗺️ Obteniendo coordenadas para place ID: $placeId');

    try {
      // Usamos la nueva Places API (New) para obtener detalles del lugar
      final String url = 'https://places.googleapis.com/v1/places/$placeId';
      
      print('🌐 Consultando Places API (New) para coordenadas: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'location'
        },
      );

      print('📡 Respuesta Places API coordenadas: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📥 Datos de coordenadas: $data');
        
        if (data['location'] != null) {
          final location = data['location'];
          final coordinates = <String, double>{
            'latitude': (location['latitude'] as num).toDouble(),
            'longitude': (location['longitude'] as num).toDouble(),
          };
          print('✅ Coordenadas de Places API (New) obtenidas: $coordinates');
          return coordinates;
        }
      } else {
        print('❌ Error en Places API coordenadas: ${response.statusCode} - ${response.body}');
        // Fallback a la API clásica de Place Details
        return await _getPlaceDetailsClassic(placeId);
      }
    } catch (e) {
      print('❌ Error en Places API (New) coordenadas: $e');
      // Fallback a la API clásica
      return await _getPlaceDetailsClassic(placeId);
    }

    return null;
  }

  static Future<Map<String, double>?> _getPlaceDetailsClassic(String placeId) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry'
          '&key=$apiKey';

      print('🌐 Fallback - Consultando Place Details clásico: $url');

      final response = await http.get(Uri.parse(url));
      print('📡 Respuesta Place Details clásico: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final location = data['result']['geometry']['location'];
          final coordinates = <String, double>{
            'latitude': (location['lat'] as num).toDouble(),
            'longitude': (location['lng'] as num).toDouble(),
          };
          print('✅ Coordenadas de API clásica obtenidas: $coordinates');
          return coordinates;
        } else {
          print('❌ Error en Place Details: ${data['status']}');
        }
      } else {
        print('❌ Error HTTP Place Details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting place coordinates: $e');
    }
    return null;
  }
}

class GooglePlacesAutoCompleteWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final Icon? prefixIcon;
  final List<Widget>? suffixIcons;
  final Function(PlacePrediction)? onPlaceSelected;
  final String? Function(String?)? validator;

  const GooglePlacesAutoCompleteWidget({
    Key? key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcons,
    this.onPlaceSelected,
    this.validator,
  }) : super(key: key);

  @override
  State<GooglePlacesAutoCompleteWidget> createState() => _GooglePlacesAutoCompleteWidgetState();
}

class _GooglePlacesAutoCompleteWidgetState extends State<GooglePlacesAutoCompleteWidget> {
  List<PlacePrediction> _predictions = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(widget.controller.text);
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _isLoading = false;
      });
      _removeOverlay();
      return;
    }

    setState(() => _isLoading = true);

    final predictions = await GooglePlacesService.getAutocompletePredictions(query);
    
    if (mounted) {
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
      
      if (predictions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    // Usar post frame callback para evitar errores de tamaño durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          width: MediaQuery.of(context).size.width - 32, // Ancho de pantalla menos padding
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 60),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.grey),
                      title: Text(
                        prediction.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => _selectPlace(prediction),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      if (mounted) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectPlace(PlacePrediction prediction) async {
    widget.controller.text = prediction.description;
    _removeOverlay();
    _focusNode.unfocus();
    
    if (widget.onPlaceSelected != null) {
      print('🔍 Obteniendo coordenadas para: ${prediction.description}');
      // Obtener coordenadas del lugar seleccionado
      final coordinates = await GooglePlacesService.getPlaceCoordinates(prediction.placeId);
      if (coordinates != null) {
        print('✅ Coordenadas obtenidas: $coordinates');
        final updatedPrediction = PlacePrediction(
          description: prediction.description,
          placeId: prediction.placeId,
          latitude: coordinates['latitude'],
          longitude: coordinates['longitude'],
        );
        widget.onPlaceSelected!(updatedPrediction);
      } else {
        print('❌ No se pudieron obtener las coordenadas');
        widget.onPlaceSelected!(prediction);
      }
    }
    
    setState(() => _predictions = []);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcons != null && widget.suffixIcons!.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading) 
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ...widget.suffixIcons!,
                      ],
                    )
                  : _isLoading 
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
            ),
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}
