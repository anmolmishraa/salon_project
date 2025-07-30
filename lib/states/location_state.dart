import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionGranted extends LocationState {
  final Position position;
  final String placeName;

  LocationPermissionGranted(this.position, this.placeName);

  @override
  List<Object?> get props => [position, placeName];
}

class LocationPermissionDenied extends LocationState {}

class LocationPermissionPermanentlyDenied extends LocationState {}

class LocationServicesDisabled extends LocationState {}

class LocationSettingsOpened extends LocationState {}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
