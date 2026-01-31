import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';

import '../../generated/l10n.dart';
import '../1.constants/route_constants.dart';
import '../studioDetail/event_argument_model.dart';

class LanguagesViewRoute extends StatefulWidget {
  const LanguagesViewRoute({super.key});

  @override
  State<LanguagesViewRoute> createState() => _LanguagesViewRouteState();
}

class _LanguagesViewRouteState extends State<LanguagesViewRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerLeft,
              colors: [Color(0xFF003B73), Color(0xFFd2e6f7)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: S.of(context).languages,
          isCenterTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setLocale('ta');
                  },
                  child: const Text('Tamil')),
              ElevatedButton(
                  onPressed: () {
                    setLocale('en');
                    },
                  child: const Text('English')),
            ],
          ),
        ),
      ),
    );
  }

  void setLocale(String locale) {
    setState(() {
      S.load(Locale(locale));
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        RoutePaths.sideMenuView,
          arguments: SideMenuArguments(0)
      );
    });
  }
}
