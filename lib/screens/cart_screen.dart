// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User is not logged in');
      }

    // Remove unnecessary null and type checks
      final response = await _supabase
          .from('cart')
          .select(
              'product_id, quantity, created_at, products(name, price, image_url)')
          .eq('user_id', userId);

      final items = response
          .map<Map<String, dynamic>>((item) {
            final product = item['products'] as Map<String, dynamic>?;

            if (product == null) {
              return {}; // Skip incomplete items
            }

            return {
              'product_id': item['product_id'],
              'quantity': item['quantity'] ?? 0,
              'created_at': item['created_at'],
              'name': product['name'] ?? 'Unknown Product',
              'price': product['price'] ?? 0.0,
              'image_url':
                  product['image_url'] ?? 'https://mnpebbfvgyzltuvillbu.supabase.co/storage/v1/object/public/photos/logo/logo.png',
            };
          })
          .where((item) => item.isNotEmpty)
          .toList();

      final total = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );

      setState(() {
        _cartItems = items;
        _totalPrice = total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User is not logged in');
      }

      // Update the quantity of the product in the cart
      await _supabase
          .from('cart')
          .update({'quantity': quantity})
          .eq('user_id', userId)
          .eq('product_id', productId);

      _loadCart(); // Refresh the cart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeFromCart(String productId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User is not logged in');
      }

      // Remove the product from the cart
      await _supabase
          .from('cart')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);

      _loadCart(); // Refresh the cart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard appears
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    leading: Image.network(
                      item['image_url'] ?? 'https://mnpebbfvgyzltuvillbu.supabase.co/storage/v1/object/public/photos/logo/logo.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: Rs ${item['price'].toStringAsFixed(2)}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  _updateQuantity(
                                      item['product_id'], item['quantity'] - 1);
                                }
                              },
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(
                                    item['product_id'], item['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeFromCart(item['product_id']);
                      },
                    ),
                  ),
                );
              },
            ),
     bottomNavigationBar: BottomAppBar(
        child: SafeArea(
          child: SingleChildScrollView(
            // Prevents overflow
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensures it doesn't take more space than needed
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rs ${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to checkout page
                      Navigator.pushNamed(context, '/checkout', arguments: {
                        'cartItems': _cartItems,
                        'totalPrice': _totalPrice,
                      });
                    },
                    child: const Text('Proceed to Checkout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
