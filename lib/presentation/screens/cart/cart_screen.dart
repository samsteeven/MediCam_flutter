import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _items = [
    {'id': 'MED-1', 'name': 'Paracétamol 500mg', 'price': 3.5, 'qty': 1},
    {'id': 'MED-2', 'name': 'Vitamine C 1000mg', 'price': 7.0, 'qty': 2},
  ];

  double get _total => _items.fold(
    0.0,
    (s, e) => s + (e['price'] as double) * (e['qty'] as int),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final it = _items[i];
                  return ListTile(
                    title: Text(it['name']),
                    subtitle: Text('${it['price'].toStringAsFixed(2)} €'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed:
                              () => setState(
                                () =>
                                    it['qty'] =
                                        (it['qty'] as int) - 1 > 0
                                            ? (it['qty'] as int) - 1
                                            : 1,
                              ),
                        ),
                        Text('${it['qty']}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed:
                              () => setState(
                                () => it['qty'] = (it['qty'] as int) + 1,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: {'items': _items},
                      ),
                  child: const Text('Commander'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
