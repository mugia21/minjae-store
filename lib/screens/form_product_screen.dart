import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class FormProductScreen extends StatefulWidget {
  final Product? product;

  const FormProductScreen({
    super.key,
    this.product,
  });

  @override
  State<FormProductScreen> createState() => _FormProductScreenState();
}

class _FormProductScreenState extends State<FormProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _brandController;
  late TextEditingController _stockController;
  late TextEditingController _thumbnailController;

  bool _saving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _titleController =
        TextEditingController(text: product?.title ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _categoryController =
        TextEditingController(text: product?.category ?? '');
    _priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    _brandController =
        TextEditingController(text: product?.brand ?? '');
    _stockController =
        TextEditingController(text: product?.stock.toString() ?? '');
    _thumbnailController =
        TextEditingController(text: product?.thumbnail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _stockController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _categoryController.text.trim(),
      'price': double.parse(_priceController.text),
      'brand': _brandController.text.trim(),
      'stock': int.parse(_stockController.text),
      'thumbnail': _thumbnailController.text.trim(),
    };

    final provider = context.read<ProductProvider>();

    final success = isEditing
        ? await provider.updateProduct(widget.product!.id, data)
        : await provider.addProduct(data);

    if (!mounted) return;

    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Produk berhasil diperbarui!'
                : 'Produk berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Terjadi kesalahan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppTheme.primaryPink,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (isRequired &&
                  (value == null || value.trim().isEmpty)) {
                return '$label tidak boleh kosong';
              }

              if (value != null && value.trim().isNotEmpty) {
                if (label == 'Price') {
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                }

                if (label == 'Stock') {
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Masukkan stok yang valid';
                  }
                }

                if (label == 'Image URL') {
                  final uri = Uri.tryParse(value);
                  if (uri == null ||
                      !uri.hasScheme ||
                      !['http', 'https'].contains(uri.scheme)) {
                    return 'Masukkan URL gambar yang valid';
                  }
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    isEditing
                        ? Icons.edit_note
                        : Icons.add_shopping_cart,
                    size: 55,
                    color: AppTheme.primaryPink,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    isEditing
                        ? 'Update your product'
                        : 'Add a new product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildTextField(
                  label: 'Product Name',
                  controller: _titleController,
                  hint: 'Enter product name',
                ),
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'Enter product description',
                  maxLines: 3,
                ),
                _buildTextField(
                  label: 'Category',
                  controller: _categoryController,
                  hint: 'Example: beauty',
                ),
                _buildTextField(
                  label: 'Price',
                  controller: _priceController,
                  hint: 'Enter product price',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  label: 'Brand',
                  controller: _brandController,
                  hint: 'Enter brand name',
                ),
                _buildTextField(
                  label: 'Stock',
                  controller: _stockController,
                  hint: 'Enter stock quantity',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  label: 'Image URL',
                  controller: _thumbnailController,
                  hint: 'https://example.com/image.jpg',
                  isRequired: false,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: AppTheme.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(
                            isEditing
                                ? 'Save Changes'
                                : 'Add Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}