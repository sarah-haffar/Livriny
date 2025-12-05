// lib/screens/tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final String orderStatus;
  final String restaurantName;
  final String restaurantAddress;
  final String deliveryAddress;
  final double orderTotal;
  final DateTime estimatedDelivery;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.orderStatus,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.deliveryAddress,
    required this.orderTotal,
    required this.estimatedDelivery,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Coordonnées simulées
  static const LatLng _restaurantPosition = LatLng(48.8566, 2.3522); // Paris
  static const LatLng _deliveryPosition = LatLng(48.8584, 2.2945); // Tour Eiffel
  LatLng _driverPosition = _restaurantPosition;
  LatLng _previousDriverPosition = _restaurantPosition;

  // Données du livreur
  final String _driverName = 'Jean Martin';
  final String _driverPhone = '06 12 34 56 78';
  final String _vehicle = 'Scooter électrique';
  final String _licensePlate = 'AB-123-CD';
  final String _driverRating = '4.8';

  // État de la livraison
  double _deliveryProgress = 0.0;
  String _currentStatus = 'En préparation';
  String _estimatedTime = '20-25 min';
  int _timeRemaining = 20; // minutes

  Timer? _trackingTimer;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startTrackingSimulation();
    _updateOrderStatus();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _initializeMap() {
    // Marqueurs fixes : restaurant et livraison
    _markers.addAll([
      Marker(
        markerId: const MarkerId('restaurant'),
        position: _restaurantPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.restaurantName,
          snippet: widget.restaurantAddress,
        ),
      ),
      Marker(
        markerId: const MarkerId('delivery'),
        position: _deliveryPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Votre adresse',
          snippet: widget.deliveryAddress,
        ),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: _driverName,
          snippet: 'En route vers vous',
        ),
      ),
    ]);

    // Trajet principal
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 4,
      points: [_restaurantPosition, _deliveryPosition],
    ));

    // Trajet du livreur
    _polylines.add(Polyline(
      polylineId: const PolylineId('driver_path'),
      color: Colors.blue.withOpacity(0.5),
      width: 2,
      points: [_restaurantPosition, _driverPosition],
    ));
  }

  void _startTrackingSimulation() {
    final totalDistance = _calculateDistance(_restaurantPosition, _deliveryPosition);
    final totalTimeSec = 20 * 60; // 20 minutes de livraison simulée
    int elapsedSec = 0;

    _trackingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      _previousDriverPosition = _driverPosition;

      // Avancer le livreur proportionnellement
      elapsedSec += 3;
      double fraction = (elapsedSec / totalTimeSec).clamp(0.0, 1.0);
      _driverPosition = LatLng(
        _restaurantPosition.latitude +
            (_deliveryPosition.latitude - _restaurantPosition.latitude) * fraction,
        _restaurantPosition.longitude +
            (_deliveryPosition.longitude - _restaurantPosition.longitude) * fraction,
      );

      // Mettre à jour le marqueur du livreur
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: _driverName,
          snippet: 'Distance restante: ${(_calculateDistance(_driverPosition, _deliveryPosition)).toStringAsFixed(1)} km',
        ),
        rotation: _calculateBearing(_previousDriverPosition, _driverPosition),
      ));

      // Mettre à jour le polyline du livreur
      _polylines.removeWhere((p) => p.polylineId.value == 'driver_path');
      _polylines.add(Polyline(
        polylineId: const PolylineId('driver_path'),
        color: Colors.blue.withOpacity(0.5),
        width: 2,
        points: [_restaurantPosition, _driverPosition],
      ));

      // Progression
      _deliveryProgress = fraction;
      _timeRemaining = ((1 - fraction) * 20).ceil();
      _estimatedTime = '$_timeRemaining-${_timeRemaining + 5} min';

      // Centrer la map sur le livreur
      _mapController.animateCamera(CameraUpdate.newLatLng(_driverPosition));

      if (fraction >= 1.0) {
        timer.cancel();
        _currentStatus = 'Arrivé';
      }

      setState(() {});
    });
  }

  void _updateOrderStatus() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      setState(() {
        if (_deliveryProgress < 0.3) {
          _currentStatus = 'En préparation';
        } else if (_deliveryProgress < 0.6) {
          _currentStatus = 'En route';
        } else if (_deliveryProgress < 0.9) {
          _currentStatus = 'Presque arrivé';
        } else {
          _currentStatus = 'Arrivé bientôt';
          timer.cancel();
        }
      });
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double kmPerDegree = 111.0;
    final latDiff = (end.latitude - start.latitude).abs();
    final lngDiff = (end.longitude - start.longitude).abs();
    return (latDiff + lngDiff) * kmPerDegree;
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (pi / 180);
    final lon1 = start.longitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);
    final lon2 = end.longitude * (pi / 180);

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  void _callDriver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appeler le livreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous appeler $_driverName ?'),
            const SizedBox(height: 8),
            Text(
              _driverPhone,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Appel vers $_driverPhone...'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
            child: const Text('APPELER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendMessageToDriver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un message'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Votre message au livreur...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message envoyé au livreur'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
            child: const Text('ENVOYER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de livraison'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (_restaurantPosition.latitude + _deliveryPosition.latitude) / 2,
                    (_restaurantPosition.longitude + _deliveryPosition.longitude) / 2,
                  ),
                  zoom: 13,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) => _mapController = controller,
                zoomControlsEnabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_currentStatus, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_estimatedTime, style: const TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _deliveryProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Restaurant', style: TextStyle(fontSize: 12)),
                      Text('${(_deliveryProgress * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                      const Text('Chez vous', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
