import 'package:flutter/material.dart';

class CommonCircularProgress extends StatelessWidget {
  const CommonCircularProgress({Key? key, this.value}) : super(key: key);
  final double? value;
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* CircularProgressIndicator(
            backgroundColor:Colors.red,
            strokeWidth:5,
            value: value,
            color: Colors.grey,
          ),*/
          // const Padding(padding: EdgeInsets.all(5)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(" Please Wait",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              /*Blinkingwidget(
                child: Text(".",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
              ),
              Blinkingwidget(
                child: Text(".",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
              ),
              Blinkingwidget(
                child: Text(".",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
              ),*/
            ],
          )
        ],
      ),
    );
  }
}
