import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Management App',
      theme: AppTheme.light,
      initialRoute: AppRouter.authGate,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
