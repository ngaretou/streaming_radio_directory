import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/channels_grid.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 5),
          child: const ChannelsGrid(),
        ),
      ),
    );
  }
}
