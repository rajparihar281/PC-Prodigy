import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techy_store/screens/setting_screen.dart';

// Import all screens
import 'screens/cart_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/checkout_screen.dart';
// import 'screens/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'ADD YOUR DATABASE URL',
    anonKey: 'ADD YOUR ANON KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Prodigy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => const SignupScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/search':
            return MaterialPageRoute(
              builder: (_) => const SearchScreen(),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            );
          case '/product':
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                product: settings.arguments as Map<String, dynamic>,
              ),
            );
          case '/checkout':
            return MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                product: settings.arguments as Map<String, dynamic>,
              ),
            );
          case '/cart':
            return MaterialPageRoute(
              builder: (_) => const CartScreen(),
            );
            case '/setting':
            return MaterialPageRoute(
              builder: (_) => const SettingScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
        }
      },
    );
  }
}
