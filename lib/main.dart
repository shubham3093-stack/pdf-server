import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditional import
import 'pdf_view_mobile.dart'
    if (dart.library.html) 'pdf_view_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Fetch Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PdfFetchPage(),
    );
  }
}

class PdfFetchPage extends StatelessWidget {
  const PdfFetchPage({super.key});

  final String fileId = "14fWiw9XZ09JriNhudbtmaLNHpZzRRDdK";

  @override
  Widget build(BuildContext context) {
    final pdfUrl = kIsWeb
        ? "https://drive.google.com/file/d/$fileId/preview"
        : "https://drive.google.com/uc?export=download&id=$fileId";

    return PdfView(url: pdfUrl); // Works on all platforms now
  }
}
