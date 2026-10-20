import 'dart:convert';

import 'package:examen/models/product.dart';
import 'package:examen/services/product_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const product = Product(
    id: 7,
    title: 'Bolso',
    price: 25.5,
    description: 'Bolso de prueba',
    category: 'accesorios',
    image: 'https://example.com/bolso.png',
  );

  test('obtiene y convierte productos desde la API', () async {
    final service = ProductApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 7,
              ...product.toJson(),
              'rating': {'rate': 4.5, 'count': 12},
            },
          ]),
          200,
        ),
      ),
    );

    final products = await service.getProducts();

    expect(products, hasLength(1));
    expect(products.single.id, 7);
    expect(products.single.rating, 4.5);
    expect(products.single.ratingCount, 12);
  });

  test('envía POST, PUT y DELETE a los endpoints de productos', () async {
    final requests = <String>[];
    final service = ProductApiService(
      client: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        if (request.method == 'POST') {
          return http.Response('{"id": 41}', 200);
        }
        return http.Response('{}', 200);
      }),
    );

    final created = await service.createProduct(product);
    final updated = await service.updateProduct(product);
    await service.deleteProduct(product.id!);

    expect(created.id, 41);
    expect(updated, product);
    expect(requests, [
      'POST /products',
      'PUT /products/7',
      'DELETE /products/7',
    ]);
  });

  test('expone errores HTTP en lugar de ocultarlos', () async {
    final service = ProductApiService(
      client: MockClient((_) async => http.Response('No disponible', 503)),
    );

    expect(
      service.getProducts(),
      throwsA(
        isA<ProductApiException>().having(
          (error) => error.message,
          'message',
          contains('503'),
        ),
      ),
    );
  });
}
