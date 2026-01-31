import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class SplitView extends StatefulWidget {
  final List<Widget> children;
  final double ? area ;

  const SplitView({Key? key, required this.children, this.area}) : super(key: key);

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
          dividerThickness: 1,
          dividerPainter: DividerPainters.background(color: Colors.black)),
      child: MultiSplitView(resizable: true,
          initialAreas: (Platform.isAndroid) ?[
            Area(weight: widget.area??.75),

          ]:[Area(weight: .30),],
          axis: (Platform.isAndroid) ? Axis.vertical : Axis.horizontal,
          children: (Platform.isAndroid)
              ? widget.children.reversed.toList()
              : widget.children,
          onDividerTap: (dividerIndex) => {},
          onDividerDoubleTap: (dividerIndex) => {}),
    );
  }
}
