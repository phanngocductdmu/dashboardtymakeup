import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCpba4RbZJeuPxruLQP3NPsMYd1VYY_O7o',
      appId: '1:365453936537:web:511b120bfe8e2f87e27508',
      messagingSenderId: '365453936537',
      projectId: 'ty-makeup',
      authDomain: 'ty-makeup.firebaseapp.com',
      databaseURL: 'https://ty-makeup-default-rtdb.firebaseio.com',
      storageBucket: 'ty-makeup.firebasestorage.app',
      measurementId: 'G-EGKJXK60XK',
    ),
  );
  runApp(const MyDashboardApp(isLoggedIn: false));
}

class MyDashboardApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyDashboardApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? DashboardPage() : LoginPage(),
    );
  }
}
