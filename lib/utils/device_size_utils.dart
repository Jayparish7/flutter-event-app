import 'package:flutter/material.dart';

class DeviceSizeUtils {


  static double getTextWidth(String text ){
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Colors.deepOrange,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final double textWidth = textPainter.width + 30;

    return textWidth;
  }



}