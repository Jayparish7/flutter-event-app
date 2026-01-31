import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final Widget? child ;
  final BorderRadiusGeometry? shape ;
  const CommonCard({Key? key, this.child, this.shape}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Card(
        shape: RoundedRectangleBorder(
          borderRadius: shape ??  BorderRadius.circular(8.0),
        ),
      //  elevation: AppColorData.cardElevation,
       // shadowColor: AppColorData.cardShadowColor,
        color: Colors.transparent,
      //  margin: AppColorData.cardMargin,
        child : ClipRRect(
          borderRadius: shape ??  BorderRadius.circular(8.0),
          child: Container(
              /*decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: ,
                      end: ,
                      colors: ,
                      stops: )),*/
              child: child),
        )
    );
  }
}