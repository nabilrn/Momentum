import 'package:flutter/material.dart';

class MomentumLogo extends StatelessWidget {
  final double? size;

  const MomentumLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    // If size is provided, use it for both width and height
    // Otherwise, use the original implementation
    return size != null
        ? SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/momentum_logo.png',
        fit: BoxFit.contain,
      ),
    )
        : SizedBox(
      width: double.infinity,
      height: 200,
      child: Image.asset(
        'assets/images/momentum_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}