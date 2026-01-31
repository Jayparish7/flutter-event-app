import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';

class CommonOutlinedButton extends StatelessWidget {
  final String text ;
  final Function onTap ;
  const CommonOutlinedButton ({Key? key, required this.text, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return OutlinedButton(

      onPressed: (){

        onTap();
      },
      child:CommonText(text: text,isButton: true,),
    );
  }
}
