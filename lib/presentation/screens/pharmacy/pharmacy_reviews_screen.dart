import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/review_provider.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';

class PharmacyReviewsScreen extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;
  const PharmacyReviewsScreen({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
  });

  @override
  State<PharmacyReviewsScreen> createState() => _PharmacyReviewsScreenState();
}

class _PharmacyReviewsScreenState extends State<PharmacyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ReviewProvider>().fetchPharmacyReviews(widget.pharmacyId);
      } catch (e) {
        debugPrint('Error fetching pharmacy reviews: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avis sur ${widget.pharmacyName}')),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.pharmacyReviews.isEmpty) {
            return const Center(
              child: Text('Aucun avis pour cette pharmacie.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pharmacyReviews.length,
            separatorBuilder: (context, i) => const Divider(),
            itemBuilder: (context, i) {
              final review = provider.pharmacyReviews[i];
              return ListTile(
                leading: Icon(Icons.star, color: Colors.amber, size: 32),
                title: Text('${review.rating}/5'),
                subtitle: Text(review.comment),
                trailing: Text(
                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
