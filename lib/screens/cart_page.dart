import 'package:app/events/cart_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/blocs/cart_bloc.dart';

import 'package:app/states/cart_state.dart';
import 'package:app/widgets/pay_dailog.dart';
import '../models/service_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          double additionalFee = 50;
          double convenienceFee = 100;

          double discount = 0;
          if (state.appliedCoupon == "DSalon" && state.total >= 1000) {
            discount = 500;
          }

          double finalAmount =
              state.total + additionalFee + convenienceFee - discount;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Cart"),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context, state.services);
                },
              ),
            ),
            body: state.services.isEmpty
                ? const Center(
                    child: Text(
                      "Your cart is empty.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Your Services Order",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, state.services),
                            child: const Text(
                              "+ Add more",
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ...state.services.map(
                        (service) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "For Male",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const Text(
                                    "60 Mins",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${service.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            RemoveService(service),
                                          );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.brown),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.brown),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Offers & Discounts",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.local_offer_outlined),
                            title: Text(
                              state.appliedCoupon == null
                                  ? "Apply Coupon"
                                  : "Coupon: ${state.appliedCoupon}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: () {
                              context.read<CartBloc>().add(ApplyCoupon("DSalon"));
                            },
                          ),
                        ],
                      ),
                      const Divider(),

                      const SizedBox(height: 8),
                      const Text(
                        "Payment Summary",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _summaryRow(
                              "Selected Services",
                              "₹${state.total.toStringAsFixed(0)}",
                            ),
                            _summaryRow("Additional Fee", "₹$additionalFee"),
                            _summaryRow("Convenience Fee", "₹$convenienceFee"),
                            if (discount > 0)
                              _summaryRow(
                                "Coupon Discount",
                                "- ₹${discount.toStringAsFixed(0)}",
                              ),
                            const Divider(),
                            _summaryRow(
                              "Payable Amount",
                              "₹${finalAmount.toStringAsFixed(0)}",
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: state.services.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total ₹${finalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            DateTime appointmentDateTime = DateTime.now().add(
                              const Duration(days: 1, hours: 8),
                            );

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => BookingConfirmationDialog(
                                appointmentDateTime: appointmentDateTime,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Pay",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
