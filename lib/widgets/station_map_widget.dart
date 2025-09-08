import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/station_model.dart';

class StationMapWidget extends StatefulWidget {
  final StationModel station;
  final double height;

  const StationMapWidget({
    Key? key,
    required this.station,
    this.height = 200,
  }) : super(key: key);

  @override
  State<StationMapWidget> createState() => _StationMapWidgetState();
}

class _StationMapWidgetState extends State<StationMapWidget> {
  GoogleMapController? _controller;
  late CameraPosition _initialPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    // Coordenadas por defecto (Bogotá) si no hay coordenadas específicas
    double lat = widget.station.latitude ?? 4.7110;
    double lng = widget.station.longitude ?? -74.0721;

    _initialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 15,
    );

    _markers = {
      Marker(
        markerId: MarkerId(widget.station.id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: widget.station.name,
          snippet: widget.station.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          initialCameraPosition: _initialPosition,
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
