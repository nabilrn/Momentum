import 'package:flutter/material.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Image.asset(
        'assets/images/world_map.png',
        fit: BoxFit.contain,
      ),
    );
  }
}