import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DeliveryConfirmationScreen extends StatefulWidget {
  final Delivery delivery;

  const DeliveryConfirmationScreen({super.key, required this.delivery});

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  bool _isSubmitting = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la capture : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation de livraison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Preuve de livraison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez prendre une photo du colis livré.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Zone de "Preuve"
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                        : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Appuyer pour prendre une photo",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
              ),
            ),
            if (_imageFile != null)
              TextButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.refresh),
                label: const Text('Reprendre la photo'),
              ),

            const Spacer(),

            Consumer<DeliveryProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed:
                      _imageFile == null || provider.isLoading
                          ? null
                          : () async {
                            // Dans une vraie app, on uploaderait d'abord l'image sur un bucket (S3/Firebase)
                            // Ici on simule l'URL de réussite après avoir "choisi" le fichier local
                            final String simulatedUrl =
                                "https://storage.easypharma.com/proofs/${widget.delivery.id}.jpg";

                            await provider.completeDelivery(
                              widget.delivery.id,
                              simulatedUrl,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Livraison confirmée avec succès!',
                                  ),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child:
                      provider.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('CONFIRMER LA LIVRAISON'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
