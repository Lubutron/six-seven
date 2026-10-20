import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_api_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'login_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.apiService});

  final ProductApiService? apiService;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductApiService _api = widget.apiService ?? ProductApiService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String? _loadError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.apiService == null) _api.close();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final products = await _api.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } on ProductApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _loading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<bool> _openForm({Product? product}) async {
    final result = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    if (result == null || !mounted) return false;

    try {
      if (product == null) {
        final created = await _api.createProduct(result);
        final localId =
            created.id ??
            (_products.fold<int>(0, (max, item) {
                  final id = item.id ?? 0;
                  return id > max ? id : max;
                }) +
                1);
        setState(
          () => _products = [created.copyWith(id: localId), ..._products],
        );
      } else {
        final updated = await _api.updateProduct(result);
        setState(() {
          _products = _products
              .map((item) => item.id == updated.id ? updated : item)
              .toList(growable: false);
        });
      }
      _showMessage(
        product == null ? 'Producto agregado.' : 'Cambios guardados.',
      );
      return true;
    } on ProductApiException catch (error) {
      _showMessage(error.message);
      return false;
    }
  }

  Future<bool> _deleteProduct(Product product) async {
    final id = product.id;
    if (id == null) {
      _showMessage('No se pudo identificar el producto para eliminarlo.');
      return false;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Quieres eliminar «${product.title}» del catálogo de Lubucorp?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;

    try {
      await _api.deleteProduct(id);
      if (!mounted) return false;
      setState(
        () => _products = _products
            .where((item) => item.id != id)
            .toList(growable: false),
      );
      _showMessage('Producto eliminado.');
      return true;
    } on ProductApiException catch (error) {
      _showMessage(error.message);
      return false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUBUCORP',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catálogo Lubucorp',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172238),
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _loading
                            ? 'Cargando productos…'
                            : '${_products.length} productos en Lubucorp',
                        style: const TextStyle(color: Color(0xFF718096)),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o categoría',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpiar búsqueda',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: _loadError!,
                    onRetry: _loadProducts,
                  ),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _products.isEmpty
                          ? 'Aún no hay productos. Agrega el primero a Lubucorp.'
                          : 'No encontramos productos con esa búsqueda.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF718096)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.crossAxisExtent > 750
                          ? 3
                          : constraints.crossAxisExtent > 480
                          ? 2
                          : 1;
                      return SliverGrid.builder(
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent: 324,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => ProductDetailScreen(
                                  product: product,
                                  onEdit: () => _openForm(product: product),
                                  onDelete: () => _deleteProduct(product),
                                ),
                              ),
                            ),
                            onEdit: () => _openForm(product: product),
                            onDelete: () => _deleteProduct(product),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 42,
            color: Color(0xFF718096),
          ),
          const SizedBox(height: 12),
          const Text(
            'No pudimos cargar el catálogo de Lubucorp',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}
