import 'package:app/models/service_model.dart';

class CartState {
  final List<ServiceModel> services;
  final double total;
  final String? appliedCoupon;
  final String? errorMessage;
 

  CartState({
    required this.services,
    this.appliedCoupon,
    this.errorMessage
   
  }) : total = services.fold(0, (sum, item) => sum + item.price);

  CartState copyWith({
    List<ServiceModel>? services,
    String? appliedCoupon,
    String? errorMessage,
  
  }) {
    return CartState(
      services: services ?? this.services,
       errorMessage: errorMessage, 
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
     
    );
  }
}
