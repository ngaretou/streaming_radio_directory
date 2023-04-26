import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/channels_grid.dart';
import '../providers/theme.dart';
import '../widgets/circle_button.dart';
// import '../widgets/filter_button.dart';
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
          child: const ChannelsGrid(),
          // Column(
          //   children: [
          //     //channels layer

          //     //control button row - last as it's on the top layer
          //     // Row(
          //     //   children: [
          //     //     CircleButton(
          //     //         onPressed: () => Navigator.of(context).pop(),
          //     //         icon: const Icon(Icons.close)),
          //     //     const Expanded(
          //     //         flex: 1,
          //     //         child: SizedBox(
          //     //           width: 10,
          //     //         )),
          //     //     CircleButton(
          //     //         onPressed: () {
          //     //           ThemeModel themeProvider =
          //     //               Provider.of<ThemeModel>(context, listen: false);
          //     //           //       ThemeComponents _themeToSet = ThemeComponents(
          //     //           // brightness: Brightness.light, color: _userTheme.color);
          //     //           var brightnessToSet =
          //     //               Theme.of(context).brightness == Brightness.dark
          //     //                   ? Brightness.light
          //     //                   : Brightness.dark;
          //     //           themeProvider.setTheme(
          //     //               brightness: brightnessToSet, refresh: true);
          //     //         },
          //     //         icon: Theme.of(context).brightness == Brightness.dark
          //     //             ? const Icon(Icons.light_mode)
          //     //             : const Icon(Icons.dark_mode)),
          //     //   ],
          //     // ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
