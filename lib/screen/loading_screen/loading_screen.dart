import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/tab_logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor:
                  AlwaysStoppedAnimation<Color>(ColorPallete.darkGreenColor),
            ),
          ],
        ),
      ),
    );
  }
}
