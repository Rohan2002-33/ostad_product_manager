import 'package:flutter/material.dart';

import 'screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const OstadProductManagerApp(),
  );
}

class OstadProductManagerApp
    extends StatelessWidget {
  const OstadProductManagerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Ostad Product Manager',

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed:
          const Color(0xFF00695C),

        scaffoldBackgroundColor:
          const Color(0xFFF4F8F7),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              width: 2,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),

      home:
          const ProductListScreen(),
    );
  }
}
