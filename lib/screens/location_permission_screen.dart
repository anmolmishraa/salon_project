import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../blocs/location_bloc.dart';
import '../blocs/location_event.dart' as locEvent;
import '../blocs/location_state.dart' as locState;
import '../models/salon_model.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(locEvent.CheckLocationPermission());
    });
  }

  Future<List<SalonModel>> loadSalonsFromJson() async {
    final String response = await rootBundle.loadString('assets/salons.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => SalonModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<LocationBloc, locState.LocationState>(
          listener: (context, state) async {
            if (state is locState.LocationPermissionGranted) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              });
            } else if (state is locState.LocationPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location permission denied'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is locState.LocationServicesDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enable location services'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is locState.LocationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Main UI Components
            Widget icon = const Icon(Icons.location_pin, size: 64, color: Colors.black);
            Widget title = const Text(
              'Enable Your Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            );
            Widget subtitle = const Text(
              'Please allow us to use your location to show nearby salons.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            );

            // Show loading state
            if (state is locState.LocationLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, size: 64, color: Colors.black),
                    SizedBox(height: 20),
                    Text(
                      'Checking Location...',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: Colors.black),
                  ],
                ),
              );
            }

            // Main UI
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 20),
                    title,
                    const SizedBox(height: 10),
                    subtitle,
                    const SizedBox(height: 30),

                    // Permanently Denied
                    if (state is locState.LocationPermissionPermanentlyDenied) ...[
                      const Text(
                        'Location permission is permanently denied. Please enable it in app settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.read<LocationBloc>().add(locEvent.OpenAppSettings());
                        },
                        child: const Text('Open App Settings'),
                      ),
                    ]

                    // Services Disabled
                    else if (state is locState.LocationServicesDisabled) ...[
                      const Text(
                        'Location services are disabled. Please enable them in your device settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await Geolocator.openLocationSettings();
                          context.read<LocationBloc>().add(locEvent.CheckLocationPermission());
                        },
                        child: const Text('Open Location Settings'),
                      ),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<LocationBloc>().add(locEvent.RequestLocationPermission());
                      },
                      child: const Text('Enable Location',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
