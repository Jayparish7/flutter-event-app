import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../generated/l10n.dart';
import '../utils/device_size_utils.dart';
import 'package:get/get.dart';

class CommonElevatedButton extends StatelessWidget {
  final String text;
  final Function onTap;

  const CommonElevatedButton(
      {Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          //backgroundColor: const Color(photomallYellow).withOpacity(.5),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10)) // Text Color (Foreground color)
          ),
      onPressed: () {
        onTap();
      },
      child: CommonText(
        text: text,
        isButton: true,
      ),
    );
  }
}

class CustomPrimaryButton extends StatefulWidget {
  final String? text;
  final bool? isLeadingIcon;
  final double? height;
  final double? width;
  final VoidCallback onPressed;
  final IconData? icon;

  const CustomPrimaryButton(
      {super.key,
      required this.onPressed,
      this.icon,
      this.text,
      this.isLeadingIcon = false,
      this.height,
      this.width});

  @override
  State<CustomPrimaryButton> createState() => _CustomPrimaryButtonState();
}

class _CustomPrimaryButtonState extends State<CustomPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onHover: (value) {
        showLog('value onHover $value');
        setState(() {
          _isHovered = value;
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(photomallYellow)),
            borderRadius: BorderRadius.circular(10)),
        elevation: _isHovered ? 0 : 5,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor:
            _isHovered ? const Color(photomallYellow) : photomallBodyColor,
        // Change text color on hover
        backgroundColor: _isHovered
            ? photomallBodyColor
            : const Color(photomallYellow), // Change background color on hover
      ),
      onPressed: widget.onPressed,
      child: SizedBox(
        width: DeviceSizeUtils.getTextWidth(widget.text ?? '') ?? 55,
        height: widget.height ?? 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            (widget.icon != null && widget.isLeadingIcon == true)
                ? Icon(widget.icon,
                    color: _isHovered
                        ? const Color(photomallYellow)
                        : photomallBodyColor)
                : const SizedBox.shrink(),
            SizedBox(
                width: widget.icon != null && widget.isLeadingIcon == true
                    ? 0
                    : 3),
            // Add spacing between text and icon
            (widget.text != null)
                ? Text(
                    widget.text ?? "",
                    style: TextStyle(
                        color: _isHovered
                            ? const Color(photomallYellow)
                            : photomallBodyColor),
                  )
                : const SizedBox.shrink(),
            SizedBox(
                width: widget.icon != null && widget.isLeadingIcon == false
                    ? 3
                    : 0),
            // Add spacing between text and icon
            (widget.icon != null && widget.isLeadingIcon == false)
                ? Icon(widget.icon,
                    color: _isHovered
                        ? const Color(photomallYellow)
                        : photomallBodyColor)
                : const SizedBox.shrink(),
            // Arrow right icon
          ],
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final RxBool uploadState;
  final VoidCallback onPressed;

  const UploadButton({
    Key? key,
    required this.uploadState,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isHovered = false.obs;
    return IconButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust radius as needed
          ),
        ),
      ),
      padding: EdgeInsets.zero,
      hoverColor: Colors.blueGrey,
      onPressed: onPressed,
      icon: MouseRegion(
        onEnter: (_) => isHovered.value = true, // Set hover state to true
        onExit: (_) => isHovered.value = false,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(),
          ),
          child: Obx(
            () => Wrap(
              spacing: 5,
              children: [
                Icon(
                  uploadState.value ? Icons.pause : Icons.play_arrow,
                  color: uploadState.value ? Colors.red : Colors.green,
                ),
                CommonText(
                  text: uploadState.value ? 'Pause Upload' : 'Resume Upload',
                  style: TextStyle(
                    fontSize: 20,
                      color: isHovered.value
                          ? Colors.white
                          : const Color(photomallYellow)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
