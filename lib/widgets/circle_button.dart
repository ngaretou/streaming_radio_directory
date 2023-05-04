import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget? child;

  const CircleButton({Key? key, required this.onPressed, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              fixedSize: const Size.fromHeight(38)),
          child: child),
    );
  }
}
