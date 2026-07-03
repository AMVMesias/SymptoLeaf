import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';

/// Atom: Contenedor con gradiente de fondo reutilizable
class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const GradientContainer({
    Key? key,
    required this.child,
    this.gradient,
    this.padding,
    this.useSafeArea = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? EsquemaColor.backgroundGradient,
      ),
      child: content,
    );
  }
}
