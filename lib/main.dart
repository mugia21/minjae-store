import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'screens/list_product_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PastelStoreApp());
}

class PastelStoreApp extends StatelessWidget {
  const PastelStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pastel Store',
        theme: AppTheme.lightTheme,
        home: const ListProductScreen(),
      ),
    );
  }
}