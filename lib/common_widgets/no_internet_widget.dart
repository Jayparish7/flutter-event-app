import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(

                child: Container(
                  child: const Image(image: AssetImage('assets/images/warning_blink.gif')),
                ),
              ),
              const SizedBox(height: 20),
              const CommonText(
                text: 'Offline!',
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold
                ),
                isBody: true,

              ),
              const SizedBox(height: 20),
              const CommonText(
                text: 'Please check your Internet connection ',
                style: TextStyle(
                    fontSize: 18,


                ),
                isBody: true,

              )
            ],
          ),
        ),
      ),
    );
  }
}
