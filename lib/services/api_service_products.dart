import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiServiceProducts {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // GET ALL PRODUCTS
  Future<ProductsResponse> getAllProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {
        'limit': limit,
        'skip': skip,
      },
    );

    return ProductsResponse.fromJson(response.data);
  }

  // GET SINGLE PRODUCT
  Future<Product> getProduct(int id) async {
    final response = await _dio.get('/products/$id');

    return Product.fromJson(response.data);
  }

  // SEARCH PRODUCTS
  Future<ProductsResponse> searchProducts(String query) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );

    return ProductsResponse.fromJson(response.data);
  }

  // PAGINATION
  Future<ProductsResponse> getProductsPaginated({
    int limit = 10,
    int skip = 0,
    String? select,
  }) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'skip': skip,
    };

    if (select != null) {
      params['select'] = select;
    }

    final response = await _dio.get(
      '/products',
      queryParameters: params,
    );

    return ProductsResponse.fromJson(response.data);
  }

  // SORT PRODUCTS
  Future<ProductsResponse> sortProducts(
    String sortBy,
    String order,
  ) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {
        'sortBy': sortBy,
        'order': order,
      },
    );

    return ProductsResponse.fromJson(response.data);
  }

  // GET CATEGORIES
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/products/categories');

    return (response.data as List)
        .map((e) => Category.fromJson(e))
        .toList();
  }

  // GET CATEGORY LIST
  Future<List<String>> getCategoryList() async {
    final response = await _dio.get('/products/category-list');

    return (response.data as List)
        .map((e) => e.toString())
        .toList();
  }

  // GET PRODUCTS BY CATEGORY
  Future<ProductsResponse> getProductsByCategory(
    String category,
  ) async {
    final response = await _dio.get(
      '/products/category/$category',
    );

    return ProductsResponse.fromJson(response.data);
  }

  // ADD PRODUCT
  Future<Product> addProduct(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/products/add',
      data: data,
    );

    return Product.fromJson(response.data);
  }

  // UPDATE PRODUCT
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/products/$id',
      data: data,
    );

    return Product.fromJson(response.data);
  }

  // PATCH PRODUCT
  Future<Product> patchProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/products/$id',
      data: data,
    );

    return Product.fromJson(response.data);
  }

  // DELETE PRODUCT
  Future<Product> deleteProduct(int id) async {
    final response = await _dio.delete('/products/$id');

    return Product.fromJson(response.data);
  }
}