import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/location_bloc.dart';
import 'blocs/spa_bloc.dart';
import 'screens/location_permission_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationBloc()),
        BlocProvider(create: (_) => SpaBloc()),
      ],
      child: MaterialApp(
        title: 'Salon Booking App',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        home: const LocationPermissionScreen(),
      ),
    );
  }
}
