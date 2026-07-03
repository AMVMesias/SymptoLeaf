import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Variantes de texto disponibles
enum AppTextVariant { title1, title2, title3, subtitle, body, caption }

/// Atom: Texto con estilos predefinidos
class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const AppText(
    this.text, {
    Key? key,
    this.variant = AppTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : super(key: key);

  /// Constructor para título principal
  const AppText.title1(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.title1,
        super(key: key);

  /// Constructor para título secundario
  const AppText.title2(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.title2,
        super(key: key);

  /// Constructor para título terciario
  const AppText.title3(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.title3,
        super(key: key);

  /// Constructor para subtítulo
  const AppText.subtitle(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.subtitle,
        super(key: key);

  /// Constructor para cuerpo de texto
  const AppText.body(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.body,
        super(key: key);

  /// Constructor para texto pequeño
  const AppText.caption(
    this.text, {
    Key? key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  })  : variant = AppTextVariant.caption,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getStyle() {
    TextStyle baseStyle;

    switch (variant) {
      case AppTextVariant.title1:
        baseStyle = Tipografia.titulo1;
        break;
      case AppTextVariant.title2:
        baseStyle = Tipografia.titulo2;
        break;
      case AppTextVariant.title3:
        baseStyle = Tipografia.titulo3;
        break;
      case AppTextVariant.subtitle:
        baseStyle = Tipografia.subtitulo;
        break;
      case AppTextVariant.body:
        baseStyle = Tipografia.cuerpo;
        break;
      case AppTextVariant.caption:
        baseStyle = Tipografia.caption;
        break;
    }

    return baseStyle.copyWith(
      color: color ?? EsquemaColor.textPrimary,
      fontWeight: fontWeight,
    );
  }
}
