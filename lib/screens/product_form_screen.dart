import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _categoryController = TextEditingController(
      text: product?.category ?? '',
    );
    _imageController = TextEditingController(text: product?.image ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Ingresa $label.' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.product;
    Navigator.of(context).pop(
      Product(
        id: previous?.id,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _categoryController.text.trim(),
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
        rating: previous?.rating ?? 0,
        ratingCount: previous?.ratingCount ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar producto' : 'Nuevo producto')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _field(
                controller: _titleController,
                label: 'Nombre',
                validator: (value) => _required(value, 'el nombre'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _priceController,
                label: 'Precio',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixText: '\$ ',
                validator: (value) {
                  final requiredError = _required(value, 'el precio');
                  if (requiredError != null) return requiredError;
                  final price = double.tryParse(value!.trim());
                  if (price == null || !price.isFinite || price <= 0) {
                    return 'Ingresa un precio mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                controller: _categoryController,
                label: 'Categoría',
                validator: (value) => _required(value, 'la categoría'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _imageController,
                label: 'URL de imagen',
                keyboardType: TextInputType.url,
                validator: (value) {
                  final requiredError = _required(value, 'la URL de imagen');
                  if (requiredError != null) return requiredError;
                  final uri = Uri.tryParse(value!.trim());
                  if (uri == null ||
                      !uri.hasAuthority ||
                      (uri.scheme != 'https' && uri.scheme != 'http')) {
                    return 'Ingresa una URL válida que comience con http o https.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                controller: _descriptionController,
                label: 'Descripción',
                maxLines: 5,
                validator: (value) => _required(value, 'la descripción'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(editing ? 'Guardar cambios' : 'Agregar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixText: prefixText),
    );
  }
}
