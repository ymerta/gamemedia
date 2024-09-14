import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameMedia',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: false,
          showSelectedLabels: false,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[850]!,
          secondary: Colors.greenAccent, // İkincil rengi burada ayarladık
        ),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData) {
          return LoginScreen();
        } else {
          return BottomNavBar(userId: snapshot.data!.uid);
        }
      },
    );
  }
}
