import 'package:flutter/material.dart';

class CommonIcon extends StatelessWidget {
  final IconData icon;
  final double? iconSize;
  final Color? color;
    const CommonIcon({Key? key, required this.icon,  this.iconSize, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(size:iconSize?? 50,icon,color: color,);
  }
}
