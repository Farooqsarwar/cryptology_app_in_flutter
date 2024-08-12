import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight = 60.0;
  final List<Color> gradientColors;
  GradientAppBar({
    Key? key,
    this.gradientColors = const [Color(0xff98dce1), Color(0xff3f5efb)],
  }) : super(key: key);
  // Constant title
  static const String title = 'SMART CRYPTOLOGY';
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0, // Remove elevation if you don't want a shadow
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}