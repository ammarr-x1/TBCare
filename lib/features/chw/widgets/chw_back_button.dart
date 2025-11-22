import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';

class ChwBackButton extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;
  final String tooltip;

  const ChwBackButton({
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.tooltip = 'Back',
  });

  Future<void> _handleBack(BuildContext context) async {
    final navigator = Navigator.of(context);
    final didPop = await navigator.maybePop();
    if (!didPop) {
      navigator.pushNamedAndRemoveUntil(
        AppConstants.chwRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        size: iconSize,
        color: iconColor ?? Colors.white,
      ),
      tooltip: tooltip,
      onPressed: () => _handleBack(context),
    );
  }
}

