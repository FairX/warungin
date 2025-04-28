// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Remove the 'users' list if it's not actually used here
  // final List<Map<String, dynamic>> users = [];

  // Add const constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme), // Apply base text theme
        primarySwatch: Colors.blue,
        // You might want to consolidate theme parts here
        appBarTheme: const AppBarTheme( // Example: Consistent AppBar theme
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
         bottomNavigationBarTheme: BottomNavigationBarThemeData( // Use main_screen's style or define here
           type: BottomNavigationBarType.fixed,
           backgroundColor: Colors.white,
           selectedItemColor: Colors.lightBlue[400],
           unselectedItemColor: Colors.grey,
           selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
           unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
         ),
      ),
      themeMode: ThemeMode.light,
      // Consider using named routes or ensure LoginScreen correctly leads to MainScreen
      home: LoginScreen(),
      // --- Example using named routes (optional) ---
      // initialRoute: '/login',
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/main': (context) => MainScreen(),
      //   // Potentially other routes
      // },
    );
  }
}