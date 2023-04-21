// https://www.kindacode.com/article/flutter-full-screen-semi-transparent-modal-dialog/
//A Goodman
import 'package:flutter/material.dart';

// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
class FullScreenModal extends ModalRoute {
  // variables passed from the parent widget
  final Widget child;

  // constructor
  FullScreenModal({
    required this.child,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.6);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(type: MaterialType.transparency, child: child);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,

      child: child,

      // add slide animation

      // child: SlideTransition(
      //   position: Tween<Offset>(
      //     begin: const Offset(0, -1),
      //     end: Offset.zero,
      //   ).animate(animation),
      //   // add scale animation
      //   child: ScaleTransition(
      //     scale: animation,
      //     child: child,
      //   ),
      // ),
    );
  }
}
