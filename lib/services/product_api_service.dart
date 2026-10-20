import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiException implements Exception {
  const ProductApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductApiService {
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _productsUri = Uri.parse(
    'https://fakestoreapi.com/products',
  );

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Future<List<Product>> getProducts() async {
    final response = await _request(() => _client.get(_productsUri));
    _ensureSuccess(response);

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('La respuesta no es una lista.');
      }
      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Producto con formato inválido.');
            }
            return Product.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException {
      throw const ProductApiException(
        'La respuesta del servidor no tiene un formato válido.',
      );
    } on TypeError {
      throw const ProductApiException(
        'La respuesta del servidor contiene datos inválidos.',
      );
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await _request(
      () => _client.post(
        _productsUri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
    );
    _ensureSuccess(response);
    final id = _readId(response.body);
    return product.copyWith(id: id);
  }

  Future<Product> updateProduct(Product product) async {
    final id = product.id;
    if (id == null) {
      throw const ProductApiException(
        'No se puede editar un producto sin identificador.',
      );
    }
    final response = await _request(
      () => _client.put(
        _productsUri.replace(path: '${_productsUri.path}/$id'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ),
    );
    _ensureSuccess(response);
    return product;
  }

  Future<void> deleteProduct(int id) async {
    final response = await _request(
      () => _client.delete(
        _productsUri.replace(path: '${_productsUri.path}/$id'),
      ),
    );
    _ensureSuccess(response);
  }

  Future<http.Response> _request(
    Future<http.Response> Function() send,
  ) async {
    try {
      return await send().timeout(_timeout);
    } on SocketException {
      throw const ProductApiException(
        'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const ProductApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    } on TimeoutException {
      throw const ProductApiException(
        'La solicitud tardó demasiado. Inténtalo de nuevo.',
      );
    }
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductApiException(
        'El servidor respondió con el error ${response.statusCode}.',
      );
    }
  }

  int? _readId(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final id = decoded['id'];
        if (id is int) return id;
        return int.tryParse('$id');
      }
    } on FormatException {
      throw const ProductApiException(
        'El servidor creó el producto, pero devolvió una respuesta inválida.',
      );
    }
    return null;
  }

  void close() => _client.close();
}
