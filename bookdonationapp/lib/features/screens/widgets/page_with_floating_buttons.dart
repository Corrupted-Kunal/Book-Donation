import 'package:flutter/material.dart';
import 'floating_action_buttons_group.dart';

/// Wrapper widget that adds floating action buttons to any page
class PageWithFloatingButtons extends StatelessWidget {
  final Widget child;

  const PageWithFloatingButtons({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const FloatingActionButtonsGroup(),
      ],
    );
  }
}

