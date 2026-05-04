import 'package:flutter/material.dart';
import 'dart:math';

class Cube3DPage extends StatefulWidget {
  const Cube3DPage({super.key});

  @override
  State<Cube3DPage> createState() => _Cube3DPageState();
}

class _Cube3DPageState extends State<Cube3DPage> {
  double angleX = 0;
  double angleY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Kubus"),
        backgroundColor: const Color(0xFF17AEBF),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            angleY += details.delta.dx * 0.01;
            angleX -= details.delta.dy * 0.01;
          });
        },
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspektif
              ..rotateX(angleX)
              ..rotateY(angleY),
            child: Stack(
              children: [
                _buildFace(Colors.red, 0, 0, 100),   // depan
                _buildFace(Colors.blue, 0, 0, -100), // belakang
                _buildFace(Colors.green, -100, 0, 0),// kiri
                _buildFace(Colors.orange, 100, 0, 0),// kanan
                _buildFace(Colors.purple, 0, -100, 0),// atas
                _buildFace(Colors.yellow, 0, 100, 0), // bawah
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFace(Color color, double x, double y, double z) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(x, y, z)
        ..rotateX(z != 0 ? 0 : (y != 0 ? pi / 2 : 0))
        ..rotateY(z != 0 ? (z > 0 ? 0 : pi) : (x != 0 ? pi / 2 : 0)),
      alignment: Alignment.center,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}