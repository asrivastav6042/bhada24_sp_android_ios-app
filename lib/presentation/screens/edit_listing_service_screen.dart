import 'package:flutter/material.dart';
import 'package:bhada24_sp/presentation/widgets/common/app_header.dart';

class EditListingServiceScreen extends StatelessWidget {
  final String esId;
  const EditListingServiceScreen({super.key, required this.esId});

  @override
  Widget build(BuildContext context) {
    // Uses the same layout as AddListingServiceScreen but pre-populates with existing data
    return Scaffold(
      appBar: const AppHeader(title: 'Edit Listing Service'),
      body: const Center(child: Text('Edit service - coming soon')),
    );
  }
}
