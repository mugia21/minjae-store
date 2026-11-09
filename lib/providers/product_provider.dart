import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  List<Product> _products = [];
  // Menyimpan ID produk yang ditambahkan sendiri
  final Set<int> _localProductIds = {};

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
    _selectedCategory = '';

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
      final nextSkip = _skip + 30;

      final result = await _api.getAllProducts(
        limit: 30,
        skip: nextSkip,
      );

      _products.addAll(result.products);
      _skip = result.skip;
    } catch (e) {
      _error = 'Gagal memuat produk berikutnya: $e';
    }

    _loading = false;
    notifyListeners();
  }

  // CREATE PRODUCT
Future<bool> addProduct(Map<String, dynamic> data) async {
  _error = null;

  try {
    final result = await _api.addProduct(data);

    // Tandai sebagai produk lokal
    _localProductIds.add(result.id);

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

  // UPDATE PRODUCT
Future<bool> updateProduct(
  int id,
  Map<String, dynamic> data,
) async {
  _error = null;

  try {
    final index = _products.indexWhere(
      (product) => product.id == id,
    );

    if (index == -1) {
      throw Exception('Produk tidak ditemukan');
    }

    // Produk bawaan API menggunakan request PUT.
    // Produk lokal cukup diperbarui di aplikasi.
    if (!_localProductIds.contains(id)) {
      await _api.updateProduct(id, data);
    }

    final currentProduct = _products[index];

    _products[index] = currentProduct.copyWith(
      title: data['title'] ?? currentProduct.title,
      description: data['description'] ?? currentProduct.description,
      category: data['category'] ?? currentProduct.category,
      price: data['price'] != null
          ? (data['price'] as num).toDouble()
          : currentProduct.price,
      brand: data['brand'] ?? currentProduct.brand,
      stock: data['stock'] != null
          ? (data['stock'] as num).toInt()
          : currentProduct.stock,
      thumbnail: data['thumbnail'] ?? currentProduct.thumbnail,
      discountPercentage: data['discountPercentage'] != null
          ? (data['discountPercentage'] as num).toDouble()
          : currentProduct.discountPercentage,
    );

    notifyListeners();
    return true;
  } catch (e) {
    _error = 'Gagal memperbarui produk: $e';

    notifyListeners();
    return false;
  }
}

  // DELETE PRODUCT
Future<bool> deleteProduct(int id) async {
  _error = null;

  try {
    // Pastikan produk tersedia
    final index = _products.indexWhere(
      (product) => product.id == id,
    );

    if (index == -1) {
      throw Exception('Produk tidak ditemukan');
    }

    // Produk bawaan API menggunakan request DELETE.
    // Produk lokal langsung dihapus dari aplikasi.
    if (!_localProductIds.contains(id)) {
      await _api.deleteProduct(id);
    }

    // Hapus dari daftar lokal
    _products.removeAt(index);

    // Hapus penanda produk lokal
    _localProductIds.remove(id);

    if (_total > 0) {
      _total--;
    }

    notifyListeners();
    return true;
  } catch (e) {
    _error = 'Gagal menghapus produk: $e';

    notifyListeners();
    return false;
  }
}
}