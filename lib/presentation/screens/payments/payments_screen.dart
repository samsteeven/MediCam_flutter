import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';
import 'package:easypharma_flutter/presentation/providers/payment_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';
import 'package:easypharma_flutter/presentation/screens/payments/receipt_screen.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';

class PaymentsScreen extends StatefulWidget {
  static const routeName = '/payments';
  final Order? order;

  const PaymentsScreen({super.key, this.order});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedMethod = 'ORANGE_MONEY';
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Si l'order n'est pas passé en props, on essaie de le voir dans les args
    final args = ModalRoute.of(context)?.settings.arguments;
    final order = widget.order ?? (args is Order ? args : null);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Paiement')),
        body: const Center(child: Text('Aucune commande spécifiée')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sécuriser le paiement')),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé Commande
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Commande',
                          '#${order.id.substring(0, 8)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Montant à payer',
                          '${order.totalAmount} FCFA',
                          isBold: true,
                          color: Colors.blue.shade800,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Méthode de paiement
                  const Text(
                    'Moyen de paiement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildMethodCard(
                    'Orange Money',
                    'ORANGE_MONEY',
                    Icons.phone_android,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildMethodCard(
                    'MTN Mobile Money',
                    'MTN_MOMO', // Correct backend enum value
                    Icons.phone_android,
                    Colors.yellow.shade800,
                  ),
                  const SizedBox(height: 12),

                  // "Carte Bancaire" removed as requested
                  const SizedBox(height: 32),

                  // Numéro de téléphone (pour Mobile Money)
                  if (_selectedMethod != 'CARD') ...[
                    const Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.validatePhone,
                      isRequired: true,
                      hintText: 'Ex: 699...',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Bouton Payer
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          provider.isLoading
                              ? null
                              : () => _processPayment(context, order),
                      child:
                          provider.isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              )
                              : Text(
                                'Payer',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espace de sécurité en bas
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 16,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue)
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, Order order) async {
    if (_selectedMethod != 'CARD' && _phoneController.text.isEmpty) {
      NotificationHelper.showError(
        context,
        'Veuillez entrer un numéro de téléphone',
      );
      return;
    }

    try {
      await context.read<PaymentProvider>().processPayment(
        orderId: order.id,
        method: _selectedMethod,
        amount: order.totalAmount, // Montant réel de la commande
        phoneNumber: _phoneController.text,
        onSuccess: (paymentData) {
          // Add local notification
          context.read<NotificationProvider>().addLocalNotification(
            NotificationDTO(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Paiement réussi !',
              message:
                  'Votre paiement de ${order.totalAmount} FCFA a été traité. Merci pour votre confiance.',
              createdAt: DateTime.now(),
              isRead: false,
              type: 'PAYMENT',
            ),
          );

          // Ensure phone number is in data for receipt
          final dataWithPhone = Map<String, dynamic>.from(paymentData);
          if (!dataWithPhone.containsKey('phoneNumber')) {
            dataWithPhone['phoneNumber'] = _phoneController.text;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptScreen(paymentData: dataWithPhone),
            ),
          );
        },
      );
    } catch (e) {
      NotificationHelper.showError(context, 'Erreur lors du paiement: $e');
    }
  }
}
