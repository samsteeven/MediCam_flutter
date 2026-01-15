import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/review_provider.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';

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
        // Default to showing approved reviews on open
        context.read<ReviewProvider>().fetchPharmacyReviews(
          widget.pharmacyId,
          status: 'APPROVED',
        );
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
              final auth = context.read<AuthProvider>();
              final isOwner =
                  auth.user?.id != null &&
                  auth.user!.id.toString().trim() ==
                      review.patientId.toString().trim();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Text(
                    (review.patientName ?? '?').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.patientName ?? 'Anonyme',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      review.comment.isNotEmpty
                          ? review.comment
                          : "(Pas de commentaire)",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontStyle:
                            review.comment.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                trailing:
                    isOwner
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Supprimer l\'avis'),
                                    content: const Text(
                                      'Voulez-vous vraiment supprimer votre avis ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirmed == true) {
                              try {
                                if (mounted) {
                                  await context
                                      .read<ReviewProvider>()
                                      .deleteReview(
                                        review.id,
                                        widget.pharmacyId,
                                      );
                                  if (context.mounted) {
                                    NotificationHelper.showSuccess(
                                      context,
                                      'Avis supprimé',
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  NotificationHelper.showError(
                                    context,
                                    'Erreur: $e',
                                  );
                                }
                              }
                            }
                          },
                        )
                        : null,
              );
            },
          );
        },
      ),
    );
  }
}
