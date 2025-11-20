import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash.dart';

Future<void> main() async {
  await dotenv.load(); // load API key
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👉 GLOBAL FONT SETUP DI SINI
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme, // kalau mau dark ganti ke dark
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
