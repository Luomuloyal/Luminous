import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';

class ResponsiveContentFrame extends StatelessWidget {
  const ResponsiveContentFrame({
    super.key,
    required this.child,
    this.expand = false,
  });

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width >= AppBreakpoints.desktop
              ? layout.maxContentWidth
              : double.infinity,
        ),
        child: child,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.pageHorizontalPadding),
      child: expand ? SizedBox.expand(child: content) : content,
    );
  }
}
