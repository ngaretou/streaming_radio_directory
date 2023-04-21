import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:streaming_radio_directory/widgets/channels_grid.dart';

import '../widgets/circle_button.dart';
import '../widgets/filter_button.dart';
// import 'package:package_info_plus/package_info_plus.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  void switchMode(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 5),
          child: Stack(
            children: [
              //channels layer
              const ChannelsGrid(),
              //control button row - last as it's on the top layer
              Row(
                children: [
                  CircleButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close)),
                  const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 10,
                      )),
                  CircleButton(
                      onPressed: () {},
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? const Icon(Icons.light_mode)
                          : const Icon(Icons.dark_mode)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
