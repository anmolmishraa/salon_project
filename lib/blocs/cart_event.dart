import 'package:app/models/service_model.dart';

abstract class CartEvent {}

class AddService extends CartEvent {
  final ServiceModel service;
  AddService(this.service);
}

class RemoveService extends CartEvent {
  final ServiceModel service;
  RemoveService(this.service);
}

class ApplyCoupon extends CartEvent {
  final String couponCode;
  ApplyCoupon(this.couponCode);
}