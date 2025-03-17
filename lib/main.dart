import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proj1/screens/login.dart';
import 'package:proj1/screens/RegisterPage.dart';
import 'package:proj1/screens/home.dart';
import 'package:proj1/screens/UsedCarScreen.dart';
import 'package:proj1/screens/FilteredUsedCarsScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Default route to Login Page
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/usedCars': (context) => UsedCarScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/filteredCars') {
          final args = settings.arguments as Map<String, int>;
          return MaterialPageRoute(
            builder: (context) => FilteredUsedCarsScreen(
              minPrice: args['minBudget']!,
              maxPrice: args['maxBudget']!,
            ),
          );
        }
        return null;
      },
    );
  }
}
