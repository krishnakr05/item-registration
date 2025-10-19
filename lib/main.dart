import 'package:flutter/material.dart';
import 'package:item_registration/Presentation/login_screen.dart';
import 'package:item_registration/Presentation/product_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:item_registration/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ScreenProductHome());
  }
}
