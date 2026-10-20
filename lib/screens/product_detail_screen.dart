import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final Future<bool> Function() onEdit;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              height: 300,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 56,
                  color: Color(0xFF9AA5B1),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(product.category),
                backgroundColor: const Color(0xFFE8F4F4),
                side: BorderSide.none,
                labelStyle: const TextStyle(
                  color: Color(0xFF087E8B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF172238),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF087E8B),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              product.description,
              style: const TextStyle(
                color: Color(0xFF526174),
                height: 1.6,
              ),
            ),
            if (product.rating > 0) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF4A340)),
                  const SizedBox(width: 5),
                  Text(
                    '${product.rating.toStringAsFixed(1)} · ${product.ratingCount} reseñas',
                    style: const TextStyle(color: Color(0xFF526174)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (await onEdit() && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      if (await onDelete() && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                    style: FilledButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
