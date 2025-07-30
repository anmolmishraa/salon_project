import 'package:app/blocs/cart_bloc.dart';
import 'package:app/models/service_model.dart';
import 'package:app/screens/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/salon_model.dart';

class SalonDetailScreen extends StatefulWidget {
  final SalonModel salon;

  const SalonDetailScreen({super.key, required this.salon});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  final Set<ServiceModel> selectedServices = {};

  bool isExpanded1 = true;
  bool isExpanded2 = false;
  bool isExpanded3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: Image.network(
                        widget.salon.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.salon.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.brown),
                            const SizedBox(width: 4),
                            Text(widget.salon.address, style: const TextStyle(fontSize: 14)),
                            const Spacer(),
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${widget.salon.rating}', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAFEF0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children:  [
                              Icon(Icons.card_giftcard, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.salon.offer.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(Icons.copy, color: Colors.green, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildChip("All", true),
                      _buildChip("Home-visit", false),
                      _buildChip("Walk-in", false),
                      _buildChip("Male", false),
                      _buildChip("Female", false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildServiceSection(
                          title: "Massage Therapy",
                          isExpanded: isExpanded1,
                          onToggle: () => setState(() => isExpanded1 = !isExpanded1),
                         
                        
                            services: widget.salon.services.map((service) {
  return _buildServiceItem(
    service.name,
   widget.salon.description,
    "₹${service.price.toInt()} • 60 Mins • Walkin", // Add duration/type if available
    service.price.toInt(),
  );
}).toList(),
                          
                        ),
                        _buildServiceSection(
                          title: "Hair Cut Wash & Style",
                          isExpanded: isExpanded2,
                          onToggle: () => setState(() => isExpanded2 = !isExpanded2),
                          services: [],
                        ),
                        _buildServiceSection(
                          title: "Nail Bar",
                          isExpanded: isExpanded3,
                          onToggle: () => setState(() => isExpanded3 = !isExpanded3),
                          services: [],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${selectedServices.length} Services added",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                     onPressed: () async {
  final updatedServices = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => CartBloc(selectedServices.toList()),
        child: const CartScreen(),
      ),
    ),
  );

  if (updatedServices != null && updatedServices is List<ServiceModel>) {
    setState(() {
      selectedServices
        ..clear()
        ..addAll(updatedServices);
    });
  }
},
                      child: const Text("Check out",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? Colors.brown : const Color(0xFFEFEFEF),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildServiceItem(String title, String dis,String subtitle, int price) {
    final service = ServiceModel(name: title, price: price.toDouble());
    final isSelected = selectedServices.contains(service);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(dis,style: TextStyle(fontSize: 12),),
                 const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Colors.grey : Colors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              setState(() {
                if (isSelected) {
                  selectedServices.remove(service);
                } else {
                  selectedServices.add(service);
                }
              });
            },
            child: Text(isSelected ? "Remove" : "Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> services,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: onToggle,
        ),
        if (isExpanded) Column(children: services),
        const Divider(),
      ],
    );
  }
}
