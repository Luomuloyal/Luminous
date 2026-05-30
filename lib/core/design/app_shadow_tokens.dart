import 'package:flutter/material.dart';

abstract final class AppShadowTokens {
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 0, spreadRadius: 0),
  ];

  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> level3 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 8,
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> level4 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> level5 = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 24),
      blurRadius: 32,
      spreadRadius: -8,
    ),
  ];
}
