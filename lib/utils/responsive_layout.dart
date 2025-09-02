import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return const EdgeInsets.all(16);
    if (width < 1200) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static double getCardWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) return width - 32;
    if (width < 900) return (width - 64) / 2;
    if (width < 1200) return (width - 96) / 3;
    return (width - 128) / 4;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet ?? desktop;
        } else {
          return desktop;
        }
      },
    );
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1200;
}

class ResponsiveSpacing {
  static double xs = 4;
  static double sm = 8;
  static double md = 16;
  static double lg = 24;
  static double xl = 32;
  static double xxl = 48;

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return EdgeInsets.symmetric(horizontal: md);
    if (width < 1200) return EdgeInsets.symmetric(horizontal: lg);
    return EdgeInsets.symmetric(horizontal: xl);
  }

  static EdgeInsets getAllPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return EdgeInsets.all(md);
    if (width < 1200) return EdgeInsets.all(lg);
    return EdgeInsets.all(xl);
  }
}
