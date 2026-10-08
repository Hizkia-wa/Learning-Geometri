import 'dart:math' as math;
import 'package:flutter/material.dart';

class Interactive3DShapeView extends StatefulWidget {
  final String shapeName; // Kubus, Balok, Tabung, Kerucut, Limas, Bola, Prisma
  final Color primaryColor;
  final bool showWireframe;
  final bool autoRotate;
  final double zoomScale;
  final bool isArMode;

  const Interactive3DShapeView({
    super.key,
    required this.shapeName,
    this.primaryColor = const Color(0xFF17AEBF),
    this.showWireframe = false,
    this.autoRotate = false,
    this.zoomScale = 1.0,
    this.isArMode = false,
  });

  @override
  State<Interactive3DShapeView> createState() => _Interactive3DShapeViewState();
}

class _Interactive3DShapeViewState extends State<Interactive3DShapeView>
    with SingleTickerProviderStateMixin {
  double _angleX = 0.4;
  double _angleY = 0.6;
  double _currentZoom = 1.0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.zoomScale;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        if (widget.autoRotate) {
          setState(() {
            _angleY += 0.015;
          });
        }
      });

    if (widget.autoRotate) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Interactive3DShapeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRotate != oldWidget.autoRotate) {
      if (widget.autoRotate) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
    if (widget.zoomScale != oldWidget.zoomScale) {
      setState(() {
        _currentZoom = widget.zoomScale;
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _angleY += details.delta.dx * 0.01;
          _angleX -= details.delta.dy * 0.01;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _currentZoom = (_currentZoom * details.scale).clamp(0.5, 2.5);
        });
      },
      child: Container(
        color: widget.isArMode ? Colors.transparent : const Color(0xFF0F172A),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isArMode)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.primaryColor.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
            CustomPaint(
              size: Size.infinite,
              painter: _Shape3DPainter(
                shapeName: widget.shapeName,
                angleX: _angleX,
                angleY: _angleY,
                zoom: _currentZoom,
                color: widget.primaryColor,
                showWireframe: widget.showWireframe,
                isArMode: widget.isArMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Point3D {
  final double x, y, z;
  _Point3D(this.x, this.y, this.z);

  _Point3D rotateX(double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    return _Point3D(x, y * cosA - z * sinA, y * sinA + z * cosA);
  }

  _Point3D rotateY(double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    return _Point3D(x * cosA + z * sinA, y, -x * sinA + z * cosA);
  }

  Offset project(double width, double height, double fov, double distance, double zoom) {
    double factor = fov / (distance + z);
    return Offset(
      width / 2 + x * factor * zoom,
      height / 2 + y * factor * zoom,
    );
  }
}

class _Polygon3D {
  final List<_Point3D> points;
  final Color color;
  final Color borderColor;

  _Polygon3D(this.points, this.color, this.borderColor);

  double get averageZ {
    double sum = 0;
    for (var p in points) {
      sum += p.z;
    }
    return sum / points.length;
  }
}

class _Shape3DPainter extends CustomPainter {
  final String shapeName;
  final double angleX;
  final double angleY;
  final double zoom;
  final Color color;
  final bool showWireframe;
  final bool isArMode;

  _Shape3DPainter({
    required this.shapeName,
    required this.angleX,
    required this.angleY,
    required this.zoom,
    required this.color,
    required this.showWireframe,
    required this.isArMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double fov = 350.0;
    final double distance = 400.0;
    final double scaleFactor = 120.0;

    List<_Polygon3D> polygons = [];

    String name = shapeName.toLowerCase();
    if (name.contains('kubus')) {
      polygons = _generateCube(scaleFactor);
    } else if (name.contains('balok')) {
      polygons = _generateBalok(scaleFactor);
    } else if (name.contains('tabung')) {
      polygons = _generateTabung(scaleFactor);
    } else if (name.contains('kerucut')) {
      polygons = _generateKerucut(scaleFactor);
    } else if (name.contains('limas')) {
      polygons = _generateLimas(scaleFactor);
    } else if (name.contains('bola')) {
      polygons = _generateBola(scaleFactor);
    } else if (name.contains('prisma')) {
      polygons = _generatePrisma(scaleFactor);
    } else {
      polygons = _generateCube(scaleFactor);
    }

    // Transform and rotate all polygons
    List<_Polygon3D> transformedPolygons = [];
    for (var poly in polygons) {
      List<_Point3D> rotatedPts = poly.points.map((pt) {
        return pt.rotateX(angleX).rotateY(angleY);
      }).toList();
      transformedPolygons.add(_Polygon3D(rotatedPts, poly.color, poly.borderColor));
    }

    // Sort by Z for Painter's Algorithm (render furthest back first)
    transformedPolygons.sort((a, b) => b.averageZ.compareTo(a.averageZ));

    // Render Polygons
    for (var poly in transformedPolygons) {
      final path = Path();
      List<Offset> projectedPoints = poly.points.map((pt) {
        return pt.project(size.width, size.height, fov, distance, zoom);
      }).toList();

      if (projectedPoints.isEmpty) continue;

      path.moveTo(projectedPoints[0].dx, projectedPoints[0].dy);
      for (int i = 1; i < projectedPoints.length; i++) {
        path.lineTo(projectedPoints[i].dx, projectedPoints[i].dy);
      }
      path.close();

      if (!showWireframe) {
        final fillPaint = Paint()
          ..color = isArMode ? poly.color.withValues(alpha: 0.85) : poly.color
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }

      final borderPaint = Paint()
        ..color = showWireframe ? color : poly.borderColor
        ..strokeWidth = showWireframe ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, borderPaint);

      // Draw vertex points in wireframe mode
      if (showWireframe) {
        final vertexPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        for (var pt in projectedPoints) {
          canvas.drawCircle(pt, 4, vertexPaint);
        }
      }
    }
  }

  List<_Polygon3D> _generateCube(double s) {
    final double h = s * 0.8;
    List<_Point3D> v = [
      _Point3D(-h, -h, -h), _Point3D(h, -h, -h),
      _Point3D(h, h, -h), _Point3D(-h, h, -h),
      _Point3D(-h, -h, h), _Point3D(h, -h, h),
      _Point3D(h, h, h), _Point3D(-h, h, h),
    ];

    Color c = color;
    return [
      _Polygon3D([v[0], v[1], v[2], v[3]], c.withValues(alpha: 0.7), Colors.cyanAccent), // Belakang
      _Polygon3D([v[4], v[5], v[6], v[7]], c.withValues(alpha: 0.85), Colors.white),       // Depan
      _Polygon3D([v[0], v[1], v[5], v[4]], c.withValues(alpha: 0.6), Colors.blueAccent),  // Atas
      _Polygon3D([v[2], v[3], v[7], v[6]], c.withValues(alpha: 0.6), Colors.blueAccent),  // Bawah
      _Polygon3D([v[0], v[3], v[7], v[4]], c.withValues(alpha: 0.75), Colors.cyan),       // Kiri
      _Polygon3D([v[1], v[2], v[6], v[5]], c.withValues(alpha: 0.75), Colors.cyan),       // Kanan
    ];
  }

  List<_Polygon3D> _generateBalok(double s) {
    final double wx = s * 1.3;
    final double hy = s * 0.7;
    final double dz = s * 0.8;

    List<_Point3D> v = [
      _Point3D(-wx, -hy, -dz), _Point3D(wx, -hy, -dz),
      _Point3D(wx, hy, -dz), _Point3D(-wx, hy, -dz),
      _Point3D(-wx, -hy, dz), _Point3D(wx, -hy, dz),
      _Point3D(wx, hy, dz), _Point3D(-wx, hy, dz),
    ];

    Color c = const Color(0xFF10B981);
    return [
      _Polygon3D([v[0], v[1], v[2], v[3]], c.withValues(alpha: 0.7), Colors.greenAccent),
      _Polygon3D([v[4], v[5], v[6], v[7]], c.withValues(alpha: 0.85), Colors.white),
      _Polygon3D([v[0], v[1], v[5], v[4]], c.withValues(alpha: 0.6), Colors.lightGreenAccent),
      _Polygon3D([v[2], v[3], v[7], v[6]], c.withValues(alpha: 0.6), Colors.lightGreenAccent),
      _Polygon3D([v[0], v[3], v[7], v[4]], c.withValues(alpha: 0.75), Colors.greenAccent),
      _Polygon3D([v[1], v[2], v[6], v[5]], c.withValues(alpha: 0.75), Colors.greenAccent),
    ];
  }

  List<_Polygon3D> _generateTabung(double s) {
    List<_Polygon3D> polys = [];
    final int segments = 24;
    final double r = s * 0.85;
    final double h = s * 1.0;

    List<_Point3D> topCircle = [];
    List<_Point3D> bottomCircle = [];

    for (int i = 0; i < segments; i++) {
      double angle = (2 * math.pi / segments) * i;
      double x = r * math.cos(angle);
      double z = r * math.sin(angle);
      topCircle.add(_Point3D(x, -h, z));
      bottomCircle.add(_Point3D(x, h, z));
    }

    Color c = const Color(0xFFF59E0B);
    polys.add(_Polygon3D(topCircle, c.withValues(alpha: 0.8), Colors.white));
    polys.add(_Polygon3D(bottomCircle.reversed.toList(), c.withValues(alpha: 0.8), Colors.amberAccent));

    for (int i = 0; i < segments; i++) {
      int next = (i + 1) % segments;
      polys.add(_Polygon3D(
        [topCircle[i], topCircle[next], bottomCircle[next], bottomCircle[i]],
        c.withValues(alpha: 0.65 + 0.2 * math.sin(i * math.pi / segments)),
        Colors.amber,
      ));
    }
    return polys;
  }

  List<_Polygon3D> _generateKerucut(double s) {
    List<_Polygon3D> polys = [];
    final int segments = 24;
    final double r = s * 0.9;
    final double h = s * 1.1;

    _Point3D apex = _Point3D(0, -h, 0);
    List<_Point3D> baseCircle = [];

    for (int i = 0; i < segments; i++) {
      double angle = (2 * math.pi / segments) * i;
      double x = r * math.cos(angle);
      double z = r * math.sin(angle);
      baseCircle.add(_Point3D(x, h, z));
    }

    Color c = const Color(0xFFEF4444);
    polys.add(_Polygon3D(baseCircle.reversed.toList(), c.withValues(alpha: 0.8), Colors.redAccent));

    for (int i = 0; i < segments; i++) {
      int next = (i + 1) % segments;
      polys.add(_Polygon3D(
        [apex, baseCircle[i], baseCircle[next]],
        c.withValues(alpha: 0.6 + 0.25 * math.cos(i * math.pi / segments)),
        Colors.orangeAccent,
      ));
    }
    return polys;
  }

  List<_Polygon3D> _generateLimas(double s) {
    final double h = s * 1.0;
    final double b = s * 0.9;

    _Point3D apex = _Point3D(0, -h, 0);
    List<_Point3D> base = [
      _Point3D(-b, h, -b),
      _Point3D(b, h, -b),
      _Point3D(b, h, b),
      _Point3D(-b, h, b),
    ];

    Color c = const Color(0xFF8B5CF6);
    return [
      _Polygon3D([base[0], base[1], base[2], base[3]], c.withValues(alpha: 0.8), Colors.purpleAccent),
      _Polygon3D([apex, base[0], base[1]], c.withValues(alpha: 0.7), Colors.white),
      _Polygon3D([apex, base[1], base[2]], c.withValues(alpha: 0.85), Colors.white),
      _Polygon3D([apex, base[2], base[3]], c.withValues(alpha: 0.65), Colors.white),
      _Polygon3D([apex, base[3], base[0]], c.withValues(alpha: 0.75), Colors.white),
    ];
  }

  List<_Polygon3D> _generateBola(double s) {
    List<_Polygon3D> polys = [];
    final int lats = 12;
    final int lons = 20;
    final double r = s * 0.95;

    Color c = const Color(0xFF3B82F6);

    for (int i = 0; i < lats; i++) {
      double lat0 = math.pi * (-0.5 + i / lats);
      double z0 = r * math.sin(lat0);
      double r0 = r * math.cos(lat0);

      double lat1 = math.pi * (-0.5 + (i + 1) / lats);
      double z1 = r * math.sin(lat1);
      double r1 = r * math.cos(lat1);

      for (int j = 0; j < lons; j++) {
        double lng0 = 2 * math.pi * (j / lons);
        double lng1 = 2 * math.pi * ((j + 1) / lons);

        _Point3D p1 = _Point3D(r0 * math.cos(lng0), z0, r0 * math.sin(lng0));
        _Point3D p2 = _Point3D(r0 * math.cos(lng1), z0, r0 * math.sin(lng1));
        _Point3D p3 = _Point3D(r1 * math.cos(lng1), z1, r1 * math.sin(lng1));
        _Point3D p4 = _Point3D(r1 * math.cos(lng0), z1, r1 * math.sin(lng0));

        polys.add(_Polygon3D(
          [p1, p2, p3, p4],
          c.withValues(alpha: 0.5 + 0.35 * math.sin((i + j) * 0.5)),
          Colors.lightBlueAccent,
        ));
      }
    }
    return polys;
  }

  List<_Polygon3D> _generatePrisma(double s) {
    final double h = s * 0.9;
    final double w = s * 0.9;

    List<_Point3D> topTri = [
      _Point3D(0, -h, -w * 0.8),
      _Point3D(w, -h, w * 0.7),
      _Point3D(-w, -h, w * 0.7),
    ];

    List<_Point3D> botTri = [
      _Point3D(0, h, -w * 0.8),
      _Point3D(w, h, w * 0.7),
      _Point3D(-w, h, w * 0.7),
    ];

    Color c = const Color(0xFFEC4899);
    return [
      _Polygon3D(topTri, c.withValues(alpha: 0.8), Colors.pinkAccent),
      _Polygon3D(botTri.reversed.toList(), c.withValues(alpha: 0.8), Colors.pinkAccent),
      _Polygon3D([topTri[0], topTri[1], botTri[1], botTri[0]], c.withValues(alpha: 0.7), Colors.white),
      _Polygon3D([topTri[1], topTri[2], botTri[2], botTri[1]], c.withValues(alpha: 0.85), Colors.white),
      _Polygon3D([topTri[2], topTri[0], botTri[0], botTri[2]], c.withValues(alpha: 0.65), Colors.white),
    ];
  }

  @override
  bool shouldRepaint(covariant _Shape3DPainter oldDelegate) {
    return oldDelegate.angleX != angleX ||
        oldDelegate.angleY != angleY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.shapeName != shapeName ||
        oldDelegate.showWireframe != showWireframe ||
        oldDelegate.isArMode != isArMode;
  }
}
