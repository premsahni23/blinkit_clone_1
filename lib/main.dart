import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({required this.id, required this.name, required this.description, required this.price, required this.imageUrl});
}


class ProductProvider with ChangeNotifier {
  final List<Product> _all = [
    Product(id: 'p1', name: 'Bananas', description: 'Fresh bananas (1 kg)', price: 40, imageUrl: 'https://picsum.photos/seed/banana/400/400'),
    Product(id: 'p2', name: 'Milk', description: 'Full cream milk (1 L)', price: 55, imageUrl: 'https://picsum.photos/seed/milk/400/400'),
    Product(id: 'p3', name: 'Eggs', description: 'Pack of 12 eggs', price: 90, imageUrl: 'https://picsum.photos/seed/eggs/400/400'),
    Product(id: 'p4', name: 'Bread', description: 'Brown bread loaf', price: 45, imageUrl: 'https://picsum.photos/seed/bread/400/400'),
    Product(id: 'p5', name: 'Tomatoes', description: 'Fresh tomatoes (500 g)', price: 35, imageUrl: 'https://picsum.photos/seed/tomato/400/400'),
    Product(id: 'p6', name: 'Apple', description: 'Red apples (1 kg)', price: 160, imageUrl: 'https://picsum.photos/seed/apple/400/400'),
    Product(id: 'p7', name: 'Rice', description: 'Basmati rice (5 kg)', price: 420, imageUrl: 'https://picsum.photos/seed/rice/400/400'),
    Product(id: 'p8', name: 'Oil', description: 'Sunflower oil (1 L)', price: 150, imageUrl: 'https://picsum.photos/seed/oil/400/400'),
  ];

  String _query = '';
  final Map<String, int> _cart = {};

  List<Product> get products {
    if (_query.isEmpty) return [..._all];
    final q = _query.toLowerCase();
    return _all.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
  }

  int get cartCount => _cart.values.fold(0, (a, b) => a + b);

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void addToCart(String productId) {
    _cart.update(productId, (v) => v + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (!_cart.containsKey(productId)) return;
    final qty = _cart[productId]! - 1;
    if (qty <= 0) _cart.remove(productId);
    else _cart[productId] = qty;
    notifyListeners();
  }

  Map<String,int> get cart => {..._cart};
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blinkit-style Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery — Demo'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _openCart(context),
              ),
              if (provider.cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text(provider.cartCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => provider.setQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => provider.setQuery(''),
                  child: const Text('Clear'),
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, p, _) {
                final list = p.products;
                if (list.isEmpty) return const Center(child: Text('No products found'));
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => ProductCard(product: list[i]),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _openCart(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final cart = provider.cart;
        if (cart.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('Cart is empty')));
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text('Your Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView(
                  children: cart.entries.map((e) {
                    final prod = provider._all.firstWhere((p) => p.id == e.key);
                    return ListTile(
                      leading: Image.network(prod.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(prod.name),
                      subtitle: Text('Qty: ${e.value}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => provider.removeFromCart(e.key), icon: const Icon(Icons.remove_circle_outline)),
                        IconButton(onPressed: () => provider.addToCart(e.key), icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Checkout (demo)'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () => provider.addToCart(product.id),
                        child: const Text('Add'),
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.network(product.imageUrl, height: 120, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(product.description),
          const SizedBox(height: 8),
          Text('Price: ₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          TextButton(onPressed: () {
            Provider.of<ProductProvider>(context, listen: false).addToCart(product.id);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
          }, child: const Text('Add to cart'))
        ],
      ),
    );
  }
}
