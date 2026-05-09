import 'package:flutter/material.dart';

class Responsive {
  // Definujeme si hranicu (breakpoint)
  static const double mobileBreakpoint = 768;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
}