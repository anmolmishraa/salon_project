import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../models/service_model.dart';
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(List<ServiceModel> initialServices)
      : super(CartState(services: initialServices, )) {
    on<RemoveService>((event, emit) {
      final updated = List<ServiceModel>.from(state.services)..remove(event.service);
      emit(state.copyWith(services: updated, appliedCoupon: null));
    });

  on<ApplyCoupon>((event, emit) {
  if (event.couponCode == "DSalon") {
    if (state.total >= 1000) {
      emit(state.copyWith(
        appliedCoupon: "DSalon",
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        appliedCoupon: null,
        errorMessage: "Minimum order value of ₹1000 required to apply this coupon.",
      ));
    }
  }
});

  }
}
