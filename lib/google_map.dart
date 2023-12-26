import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapApp extends StatefulWidget {
  const GoogleMapApp({super.key});

  @override
  State<GoogleMapApp> createState() => _GoogleMapAppState();
}

class _GoogleMapAppState extends State<GoogleMapApp> {
  Location location = Location();
  LocationData? currentLocation;
  late StreamSubscription locationSubscription;
  GoogleMapController? googleMapController;
  List<LatLng> polylineCoordinates = [];

  Future<void> getCurrentLocation() async {
    final LocationData locationData = await location.getLocation();

    locationSubscription = location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;

      final LatLng newLatLng =
          LatLng(newLocation.latitude!, newLocation.longitude!);

      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLocation.latitude!, newLocation.longitude!),
            zoom: 16,
          ),
        ),
      );

      polylineCoordinates.add(newLatLng);

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // getCurrentLocation();
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Custom Google Map"),
        ),
        body: Center(
          child: currentLocation == null
              ? const CircularProgressIndicator()
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                      infoWindow: InfoWindow(
                        title: "My current location",
                        snippet:
                            "${currentLocation!.latitude!}, ${currentLocation!.longitude!}",
                      ),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("Hafiz"),
                      points: polylineCoordinates,
                      width: 6,
                      color: Colors.teal,
                    )
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    polylineCoordinates.clear();
    locationSubscription.cancel();
    super.dispose();
  }
}
