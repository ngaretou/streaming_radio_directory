import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final void Function() onPressed;
  final Icon? icon;

  const CircleButton({Key? key, required this.onPressed, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
            
            ),
        child: icon);
  }
}
