import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class SnackbarMessages {
  static void showPositiveSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondary,
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: FlutterFlowTheme.of(context).success,
      ),
    );
  }

  static void showWarningSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: FlutterFlowTheme.of(context).warning,
      ),
    );
  }

  // Método para mostrar un snackbar negativo
  static void showNegativeSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondary,
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }
}
