import 'package:flutter/material.dart';
import 'package:roombooker/core/constants/theme.dart';
import 'package:roombooker/views/splash_view.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SplashView(),
      ),
    );
  }
}