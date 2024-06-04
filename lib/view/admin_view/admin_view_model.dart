
import '/flutter_flow/flutter_flow_util.dart';
import 'admin_view_widget.dart' show AdminViewWidget;
import 'package:flutter/material.dart';

class AdminViewModel extends FlutterFlowModel<AdminViewWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
