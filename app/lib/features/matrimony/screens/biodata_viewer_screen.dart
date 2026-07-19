import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';

class BiodataViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String profileName;

  const BiodataViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.profileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "$profileName's Biodata",
        centerTitle: true,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
