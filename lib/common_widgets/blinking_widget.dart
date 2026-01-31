import 'package:flutter/material.dart';

class Blinkingwidget extends StatefulWidget {
  final Color? color ;
  final Widget? child ;
  const Blinkingwidget({Key? key, this.color, required this.child}) : super(key: key);
  @override
  _BlinkingwidgetState createState() => _BlinkingwidgetState();
}

class _BlinkingwidgetState extends State<Blinkingwidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animationController!.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animationController!,
        child: Container(
          color: widget.color ?? Colors.transparent,
          child: widget.child,
        )
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}