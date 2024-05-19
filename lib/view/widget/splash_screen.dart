import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glutenvoid_app/index.dart';
import 'package:go_router/go_router.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: 5), // Puedes ajustar la duración de la animación aquí
    )..repeat(); // Hace que la animación gire constantemente

    Future.delayed(Duration(seconds: 5), () {
      context.go('/mainMenu'); // Navegación usando GoRouter
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          FlutterFlowTheme.of(context).secondary, // Usar color secundario
      appBar: AppBar(
        backgroundColor:
            FlutterFlowTheme.of(context).primary, // Usar color primario
        title: const Text(
          "Gluten Void",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _animationController,
                child: Transform.scale(
                  scale: 0.4, // Puedes ajustar el tamaño aquí
                  child: Image.asset('assets/images/gv_animated.gif'),
                ),
              ),
              Text('Absorbiendo gluten...', style: TextStyle(fontSize: 20)),
              // Texto justo debajo de la imagen
            ],
          ),
        ),
      ),
    );
  }
}
