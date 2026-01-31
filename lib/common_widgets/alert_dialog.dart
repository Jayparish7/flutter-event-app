import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../main.dart';

/*
class CommonAlertDialog extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;

  const CommonAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
    this.titleWidget,
    this.contentWidget,
  }) : super(key: key);

  @override
  State<CommonAlertDialog> createState() => _CommonAlertDialogState();
}

class _CommonAlertDialogState extends State<CommonAlertDialog> {
  @override
  void initState() {
    // TODO: implement initState
    showLog("the data where update ");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      backgroundColor:photomallBodyColor,

      scrollable: true,
      //titlePadding: EdgeInsets.all(10),
      //contentPadding: EdgeInsets.all(10),
      title: (widget.title == null)
          ? widget.titleWidget
          : CommonText(
              text: widget.title ?? "",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black),
              textAlign: TextAlign.left,
              //color: Theme.of(context).primaryColorDark,
              isHeading: true,
              //fontSize: TextProperty.h1,
            ),
      content: (widget.content == null)
          ? widget.contentWidget
          : Column(
              children: [
                CommonText(
                  text: widget.content ?? "",
                  textAlign: TextAlign.center,
                  isBody: true,
                  //fontSize: TextProperty.h2,
                ),
              ],
            ),

      actions: widget.actions,
    );
  }
}

*/

class CommonAlertDialog extends StatefulWidget {
  final String? title;
  final String? content;
  final Widget? titleWidget;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CommonAlertDialog({
    super.key,
    this.title,
    this.content,
    this.titleWidget,
    this.contentWidget,
    this.actions,
    this.backgroundColor,
  });

  @override
  _CommonAlertDialogState createState() => _CommonAlertDialogState();
}

class _CommonAlertDialogState extends State<CommonAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: widget.backgroundColor ?? Colors.white,
        scrollable: true,
        title: Center(
          child: widget.titleWidget ??
              Text(
                widget.title ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
        ),
        content: widget.contentWidget ??
            Text(
              widget.content ?? "",
              textAlign: TextAlign.center,
            ),
        actions: widget.actions,
      ),
    );
  }
}
