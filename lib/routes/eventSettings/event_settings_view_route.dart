import 'package:flutter/material.dart';

import '../../common_widgets/base_widget.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import '../1.constants/common_constants.dart';
import 'event_settings_view_model.dart';

class EventSettingsViewRoute extends StatefulWidget {
  final String eventCode;

  const EventSettingsViewRoute({super.key, required this.eventCode});

  @override
  State<EventSettingsViewRoute> createState() => _EventSettingsViewRouteState();
}

class _EventSettingsViewRouteState extends State<EventSettingsViewRoute> {
  BaseWidget<EventSettingsViewModel>? baseWidget;
  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: EventSettingsViewModel(),
      onModelReady: (model) async {
        await model.getInitialData(widget.eventCode);

      },
      builder: (context, model, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerLeft,
                colors: [Color(0xFF003B73), Color(0xFFd2e6f7)]),

            //fit: BoxFit.contain,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,

            body: Container(
              decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.only(topLeft: Radius.circular(20)),
                color: photomallBodyColor,
              ),
              child: Center(
                child: CommonText(
                  text: S.of(context).no_package_found,
                ),
              ),
            )

          ),
        );
      },
    );
    return baseWidget!;
  }
}
