import 'package:flutter/material.dart';
import 'dart:async';

import 'package:roombooker/views/pages/login_page.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left:20.0),
          child: Image.asset(
            'assets/images/listenlights_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, 
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/images/blue_whitebg1.jpg', fit: BoxFit.cover),

          // Centered Logo
          Center(
            child: Image.asset(
              'assets/images/roombooker_logo.png',
              width: 480,
              height: 330,
            ),
          ),
        ],
      ),
    );
  }
}
