import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat(period: Duration(seconds: 3)); // Hace que la animación se repita cada 3 segundos

    // Navega a la página principal después de 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      context.go('/mainMenu');
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
                  child: Image.asset('assets/images/gluten_void_logo.png'),
                ),
              ),
              Text('Absorbiendo gluten...', style: TextStyle(
                  fontSize: 20,
                  color: Colors.black)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
