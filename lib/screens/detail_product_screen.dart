import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import 'form_product_screen.dart';

class DetailProductScreen extends StatefulWidget {
  final Product product;

  const DetailProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailProductScreen> createState() =>
      _DetailProductScreenState();
}

class _DetailProductScreenState
    extends State<DetailProductScreen> {

  Product get product => widget.product;

  // EDIT PRODUCT
  Future<void> _editProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormProductScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  // DELETE PRODUCT
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cream,
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${product.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await context
        .read<ProductProvider>()
        .deleteProduct(product.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ProductProvider>().error ??
                'Failed to delete product',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,

      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        title: const Text(
          'Product Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),

        actions: [
          // EDIT BUTTON
          IconButton(
            onPressed: _editProduct,
            icon: const Icon(
              Icons.edit_outlined,
              color: AppTheme.textDark,
            ),
            tooltip: 'Edit Product',
          ),

          // DELETE BUTTON
          IconButton(
            onPressed: _deleteProduct,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            tooltip: 'Delete Product',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // PRODUCT IMAGE
            Container(
              width: double.infinity,
              height: 320,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 50,
                    );
                  },
                ),
              ),
            ),

            // PRODUCT INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // CATEGORY
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lavender,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TITLE
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // RATING AND STOCK
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${product.rating} Rating',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${product.stock} Stock',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // PRICE
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DESCRIPTION
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PRODUCT DETAILS
                  const Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _infoRow('Brand', product.brand),
                  _infoRow('SKU', product.sku),
                  _infoRow('Weight', '${product.weight} g'),
                  _infoRow('Warranty', product.warrantyInformation),
                  _infoRow('Shipping', product.shippingInformation),
                  _infoRow('Availability', product.availabilityStatus),
                  _infoRow('Return Policy', product.returnPolicy),

                  const SizedBox(height: 25),

                  // PRODUCT REVIEWS
                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (product.reviews.isEmpty)
                    const Text('No reviews available')
                  else
                    ...product.reviews.map(
                      (review) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppTheme.softPink,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.reviewerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text(' ${review.rating}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(review.comment),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INFORMATION ROW
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}