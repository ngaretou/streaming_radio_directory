import 'package:flutter/material.dart';

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  MySliverPersistentHeaderDelegate(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
    // Container(
    //   color: Colors.red,
    //   child: Center(
    //     child: Text(
    //       ('text'),
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 25,
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
