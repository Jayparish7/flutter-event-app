import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

class PhotomallProgress extends StatelessWidget {
  const PhotomallProgress({Key? key, this.value}) : super(key: key);
  final double? value;

  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;
    return /*Center(
        child: Image.asset(
      'assets/images/loading.png',color: Color(photomallYellow),
      height: 100,
    )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 1200.ms,
              color: Colors.yellow,
            )
            .animate() // this wraps the previous Animate in another Animate
            .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad))*/
        Center(
            child: Stack(
      children: [
        LoadingAnimationWidget.threeArchedCircle(
          key: GlobalKey(),
          color: Color(photomallYellow),
          size:  60,
        ),
        Positioned.fill(

          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/images/loading.png',
              color: const Color(photomallYellow),
              height:35,
              width: 35,
            ),
          ),
        )
      ],
    ));
  }
}
