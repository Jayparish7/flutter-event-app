import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';

class EmptyView extends StatelessWidget {
  final String text;
  final IconData iconData;

  const EmptyView({super.key, 
    required this.text,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.red
                        /* AppColor.get(context, ColorKeys.darkDividerColor)
                                .withOpacity(0.15)*/,
                        shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.assignment,
                              size: 90,


                            ),
                          ),
                          Positioned.fill(
                            //bottom: -10,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: CommonCard(

                                shape: BorderRadius.circular(100.0),

                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    iconData,
                                    size: 25,

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            CommonText(
                text: text,
              isBody: true,
              /*GoogleFonts.mulish(
                color: AppColor.get(context, ColorKeys.primaryTextColor),
                fontSize: 21,
                fontWeight: FontWeight.w300,
              ),*/
            )
          ],
        ),
      ),
    );
  }
}