import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final void Function() onPressed;
  final Icon? icon;

  const FilterButton({Key? key, required this.onPressed, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(8),
        ),
        child: icon);
  }
}
