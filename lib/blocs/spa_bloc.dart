import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/salon_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

abstract class SpaEvent {}

class LoadSpas extends SpaEvent {}

class ToggleFavorite extends SpaEvent {
  final SalonModel salon;
  ToggleFavorite(this.salon);
}

class SearchSpas extends SpaEvent {
  final String query;
  SearchSpas(this.query);
}

abstract class SpaState {}

class SpaLoading extends SpaState {}

class SpaLoaded extends SpaState {
  final List<SalonModel> allSalons;
  final List<SalonModel> filteredSalons;

  SpaLoaded({required this.allSalons, required this.filteredSalons});
}

class SpaError extends SpaState {
  final String message;
  SpaError(this.message);
}

class SpaBloc extends Bloc<SpaEvent, SpaState> {
  List<SalonModel> _allSalons = [];

  SpaBloc() : super(SpaLoading()) {
    on<LoadSpas>(_onLoadSpas);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SearchSpas>(_onSearchSpas);
  }

  Future<void> _onLoadSpas(LoadSpas event, Emitter<SpaState> emit) async {
    try {
      emit(SpaLoading());
      final String response = await rootBundle.loadString('assets/salons.json');
      final data = json.decode(response) as List;
      _allSalons = data.map((e) => SalonModel.fromJson(e)).toList();
      emit(SpaLoaded(allSalons: _allSalons, filteredSalons: _allSalons));
    } catch (e) {
      emit(SpaError("Failed to load spas"));
    }
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<SpaState> emit) {
    event.salon.isFavorite = !event.salon.isFavorite;
    emit(SpaLoaded(allSalons: _allSalons, filteredSalons: _allSalons));
  }

  void _onSearchSpas(SearchSpas event, Emitter<SpaState> emit) {
    final query = event.query.toLowerCase();
    final filtered = _allSalons.where((salon) =>
        salon.name.toLowerCase().contains(query) ||
        salon.services.any((service) => service.name.toLowerCase().contains(query))
    ).toList();

    emit(SpaLoaded(allSalons: _allSalons, filteredSalons: filtered));
  }
}
