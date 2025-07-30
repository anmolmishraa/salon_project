import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../models/salon_model.dart';
import '../widgets/salon_card.dart';

import '../blocs/location_bloc.dart';
import '../blocs/location_state.dart';
import '../blocs/location_event.dart' as loc_event;

import '../blocs/spa_bloc.dart';

import 'salon_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationBloc()..add(loc_event.FetchUserLocation())),
        BlocProvider(create: (_) => SpaBloc()..add(LoadSpas())),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBF9),
        body: SafeArea(
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              if (locationState is LocationLoading || locationState is LocationInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (locationState is LocationPermissionGranted) {
                final userPosition = locationState.position;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.brown),
                              const SizedBox(width: 4),
                              Text(locationState.placeName),
                            ],
                          ),
                          const Icon(Icons.notifications_none, color: Colors.brown),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (query) {
                          context.read<SpaBloc>().add(SearchSpas(query));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Spa, Services...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: BlocBuilder<SpaBloc, SpaState>(
                        builder: (context, spaState) {
                          if (spaState is SpaLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (spaState is SpaLoaded) {
                            final sortedSalons = [...spaState.filteredSalons]..sort(
                              (a, b) => a
                                  .distanceFrom(userPosition.latitude, userPosition.longitude)
                                  .compareTo(
                                    b.distanceFrom(userPosition.latitude, userPosition.longitude),
                                  ),
                            );

                            if (sortedSalons.isEmpty) {
                              return const Center(child: Text("No results found."));
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: sortedSalons.length,
                              itemBuilder: (context, index) {
                                final salon = sortedSalons[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SalonDetailScreen(salon: salon),
                                        ),
                                      );
                                    },
                                    child: SalonCard(
                                      salon: salon,
                                      userLat: userPosition.latitude,
                                      userLon: userPosition.longitude,
                                      onFavoriteTap: () {
                                        context.read<SpaBloc>().add(ToggleFavorite(salon));
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (spaState is SpaError) {
                            return Center(child: Text(spaState.message));
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ],
                );
              } else if (locationState is LocationError) {
                return Center(child: Text(locationState.message));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
