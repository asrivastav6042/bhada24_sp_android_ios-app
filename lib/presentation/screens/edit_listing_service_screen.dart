import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/screens/add_listing_service_screen.dart';

class EditListingServiceScreen extends StatelessWidget {
  final String esId;
  const EditListingServiceScreen({super.key, required this.esId});

  @override
  Widget build(BuildContext context) {
    return AddListingServiceScreen(editEsId: int.tryParse(esId));
  }
}
