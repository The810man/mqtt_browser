import 'package:flutter/material.dart';

bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 600;

bool isTablet(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= 600 && w < 900;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 900;

EdgeInsets screenPadding(BuildContext context) {
  if (isMobile(context)) return const EdgeInsets.all(12);
  if (isTablet(context)) return const EdgeInsets.all(20);
  return const EdgeInsets.all(24);
}
