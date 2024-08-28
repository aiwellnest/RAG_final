import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:flutter/material.dart';

class ChatField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Future<void> Function() onSubmitted;

  const ChatField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: ColorPallete.whiteColor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: ColorPallete.darkGreenColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: ColorPallete.greenColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: ColorPallete.whiteShadeColor),
        ),
        cursorColor: ColorPallete.whiteColor,
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}
