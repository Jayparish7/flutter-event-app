import 'package:flutter/material.dart';

class CommonText extends StatefulWidget {
  final String text;
  final double? textScaleFactor;
  final int? maxLines;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final bool? underline;
  final TextOverflow? overflow;
  final TextStyle? style;
  final bool isTitle; // appBar
  final bool isHeading;
  final bool isSubHeading;
  final bool isBody;
  final bool isLabel;
  final bool isButton;

  const CommonText({
    Key? key,
    required this.text,
    this.maxLines,
    this.textScaleFactor,
    this.textAlign,
    this.fontWeight,
    this.underline,
    this.overflow,
    this.style,
    this.isTitle = false,
    this.isHeading = false,
      this.isSubHeading = false,
    this.isBody = false,
    this.isLabel = false,
    this.isButton = false,
  }) : super(key: key);

  @override
  State<CommonText> createState() => _CommonTextState();
}

class _CommonTextState extends State<CommonText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      textAlign: widget.textAlign,
      textScaleFactor: widget.textScaleFactor,
      overflow: widget.overflow,
      maxLines: widget.maxLines,

      style: widget.style ?? (widget.isTitle
          ? Theme.of(context).textTheme.headlineLarge
          : widget.isHeading
              ? Theme.of(context).textTheme.headlineMedium
              : widget.isSubHeading
                  ? Theme.of(context).textTheme.headlineSmall
                  : widget.isBody
                      ? Theme.of(context).textTheme.titleMedium
                      : widget.isLabel
                          ? Theme.of(context).textTheme.labelMedium
          : widget.isButton
          ? const TextStyle(color: Colors.white)
                          : Theme.of(context).textTheme.titleLarge),
    );
  }
}




class UniqueText extends StatefulWidget {
  final String text;
  final bool? isTitle;
  final double? fontSize;
  final Color? color;

  const UniqueText({super.key, required this.text, this.isTitle = false, this.fontSize, this.color});

  @override
  State<UniqueText> createState() => _UniqueTextState();
}

class _UniqueTextState extends State<UniqueText> {
  @override
  Widget build(BuildContext context) {
    return (widget.isTitle == true)
        ? Text(
      widget.text ?? "null",
      style: TextStyle(
        color: widget.color??Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.normal,
        shadows: const <Shadow>[
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      ),
    )
        : Text(
      widget.text ?? "null",
      style: TextStyle(
        color: widget.color??Colors.white,
        fontSize: widget.fontSize !=null ? widget.fontSize:25,
        fontWeight: FontWeight.bold,
        /* shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 1.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 1.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],*/
      ),
    );
  }
}