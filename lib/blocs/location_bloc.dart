import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

import 'location_event.dart' as evt;
import 'location_state.dart' as st;

class LocationBloc extends Bloc<evt.LocationEvent, st.LocationState> {
  LocationBloc() : super(st.LocationInitial()) {
    on<evt.RequestLocationPermission>(_onRequestLocationPermission);
    on<evt.OpenAppSettings>(_onOpenAppSettings);
    on<evt.CheckLocationPermission>(_onCheckLocationPermission);
    on<evt.FetchUserLocation>(_onFetchUserLocation);
  }

  Future<void> _onRequestLocationPermission(
      evt.RequestLocationPermission event, Emitter<st.LocationState> emit) async {
    emit(st.LocationLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(st.LocationServicesDisabled());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          emit(st.LocationPermissionDenied());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(st.LocationPermissionPermanentlyDenied());
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _emitCurrentPosition(emit);
      } else {
        emit(st.LocationPermissionDenied());
      }
    } catch (e) {
      emit(st.LocationError('Error requesting location permission: ${e.toString()}'));
    }
  }

  Future<void> _onOpenAppSettings(
      evt.OpenAppSettings event, Emitter<st.LocationState> emit) async {
    try {
      await openAppSettings();
      emit(st.LocationSettingsOpened());
    } catch (e) {
      emit(st.LocationError('Failed to open app settings: ${e.toString()}'));
    }
  }

  Future<void> _onCheckLocationPermission(
      evt.CheckLocationPermission event, Emitter<st.LocationState> emit) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        emit(st.LocationServicesDisabled());
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        emit(st.LocationPermissionPermanentlyDenied());
        return;
      } else if (permission == LocationPermission.denied) {
        emit(st.LocationPermissionDenied());
        return;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _emitCurrentPosition(emit);
      } else {
        emit(st.LocationInitial());
      }
    } catch (e) {
      emit(st.LocationError('Error checking location permission: ${e.toString()}'));
    }
  }

  Future<void> _onFetchUserLocation(
      evt.FetchUserLocation event, Emitter<st.LocationState> emit) async {
    emit(st.LocationLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(st.LocationServicesDisabled());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(st.LocationPermissionDenied());
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _emitCurrentPosition(emit);
      } else {
        emit(st.LocationPermissionDenied());
      }
    } catch (e) {
      emit(st.LocationError('Failed to fetch user location: ${e.toString()}'));
    }
  }

  Future<void> _emitCurrentPosition(Emitter<st.LocationState> emit) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placeName = await getPlaceName(position.latitude, position.longitude);

      emit(st.LocationPermissionGranted(position, placeName));
    } catch (e) {
      emit(st.LocationError('Failed to get current position: ${e.toString()}'));
    }
  }
Future<String> getPlaceName(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
     
      return "${place.locality}, ${place.country}";
    }
  } catch (e) {
    print('Error in reverse geocoding: $e');
  }
  return "Unknown location";
}
}
