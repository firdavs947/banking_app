import 'package:flutter/material.dart';

class HeroText extends StatelessWidget {
  const HeroText({
    super.key,
    required this.tag,
    required this.text,
    required this.style,
  });

  final String tag;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, __, ___, ____, _____) {
        return Material(
          type: MaterialType.transparency,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: style,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Text(text, style: style),
      ),
    );
  }
}