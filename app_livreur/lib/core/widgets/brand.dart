import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Logo Livro Pro : un « G » dont la barre est une flèche.
class BrandMark extends StatelessWidget {
  final double size;
  final bool inverse;
  const BrandMark({super.key, this.size = 48, this.inverse = false});

  @override
  Widget build(BuildContext context) {
    final fond = inverse ? Colors.white : AppTheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(size * 0.225)),
      child: CustomPaint(
        painter: _LogoPainter(fond: fond, anneau: inverse ? AppTheme.primary : Colors.white),
      ),
    );
  }
}

// Même tracé que branding/livro-pro-logo.svg (repère 120 x 120)
class _LogoPainter extends CustomPainter {
  final Color fond;
  final Color anneau;
  const _LogoPainter({required this.fond, required this.anneau});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);

    Paint trait(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Anneau du G : ouvert en haut à droite
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(56, 60), radius: 29),
      0,
      312 * math.pi / 180,
      false,
      trait(anneau, 11),
    );

    final fleche = Path()
      ..moveTo(58, 60)
      ..lineTo(96, 60)
      ..moveTo(85, 49)
      ..lineTo(96, 60)
      ..lineTo(85, 71);
    canvas.drawPath(fleche, trait(fond, 17));
    canvas.drawPath(fleche, trait(AppTheme.secondary, 9));
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.fond != fond || oldDelegate.anneau != anneau;
}

/// Drapeau du Gabon dessiné (vert, jaune, bleu) — remplace l'emoji.
class GabonFlag extends StatelessWidget {
  final double width;
  const GabonFlag({super.key, this.width = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: width,
        height: width * 0.72,
        child: const Column(
          children: [
            Expanded(child: ColoredBox(color: Color(0xFF009E60), child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: Color(0xFFFCD116), child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: Color(0xFF3A75C4), child: SizedBox.expand())),
          ],
        ),
      ),
    );
  }
}
