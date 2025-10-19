import 'package:firebase_auth/firebase_auth.dart';
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
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Item Registration',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Waiting for Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // User logged in
          if (snapshot.hasData) {
            return ScreenProductHome();
          }
          // User not logged in
          return ScreenLogin();
        },
      ),
    );
  }
}
