
import '/flutter_flow/flutter_flow_util.dart';
import 'establishment_details_view_widget.dart' show EstablishmentDetailsViewWidget;
import 'package:flutter/material.dart';


class EstablishmentDetailsViewModel
    extends FlutterFlowModel<EstablishmentDetailsViewWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
