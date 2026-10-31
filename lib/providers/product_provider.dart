import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  List<Product> _products = [];
  List<String> _categoryList = [];

  bool _loading = false;
  String? _error;

  int _total = 0;
  int _skip = 0;

  String _selectedCategory = '';

  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;

  bool get loading => _loading;
  String? get error => _error;

  int get total => _total;
  String get selectedCategory => _selectedCategory;

  // GET ALL PRODUCTS
  Future<void> fetchProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getAllProducts(
        limit: limit,
        skip: skip,
      );

      _products = result.products;
      _total = result.total;
      _skip = result.skip;
    } catch (e) {
      _error = 'Gagal mengambil data produk: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // GET CATEGORIES
  Future<void> fetchCategories() async {
    try {
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (e) {
      _error = 'Gagal mengambil kategori: $e';
      notifyListeners();
    }
  }

  // SEARCH PRODUCTS
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _selectedCategory = '';
      return fetchProducts();
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.searchProducts(query);

      _products = result.products;
      _total = result.total;
    } catch (e) {
      _error = 'Pencarian gagal: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // FILTER CATEGORY
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getProductsByCategory(category);

      _products = result.products;
      _total = result.total;
    } catch (e) {
      _error = 'Gagal memfilter kategori: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // SORT PRODUCTS
  Future<void> sortProducts(
    String sortBy,
    String order,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.sortProducts(sortBy, order);

      _products = result.products;
      _total = result.total;
    } catch (e) {
      _error = 'Gagal mengurutkan produk: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // PAGINATION
  Future<void> loadMoreProducts() async {
    if (_loading || _products.length >= _total) return;

    _loading = true;
    notifyListeners();

    try {
      _skip += 30;

      final result = await _api.getAllProducts(
        limit: 30,
        skip: _skip,
      );

      _products.addAll(result.products);
    } catch (e) {
      _error = 'Gagal memuat produk berikutnya: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // UPDATE PRODUCT
  Future<bool> updateProduct(
    int id,
    Product updated,
  ) async {
    try {
      final result = await _api.updateProduct(
        id,
        updated.toJson(),
      );

      final index = _products.indexWhere((p) => p.id == id);

      if (index != -1) {
        _products[index] = result;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Gagal memperbarui produk: $e';
      notifyListeners();
      return false;
    }
  }

  // ADD PRODUCT
  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      final result = await _api.addProduct(data);

      _products.insert(0, result);
      _total++;

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambahkan produk: $e';
      notifyListeners();
      return false;
    }
  }

  // DELETE PRODUCT
  Future<bool> deleteProduct(int id) async {
    try {
      await _api.deleteProduct(id);

      _products.removeWhere((p) => p.id == id);
      _total--;

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus produk: $e';
      notifyListeners();
      return false;
    }
  }
}