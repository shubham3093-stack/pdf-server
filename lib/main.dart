import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

// ----------------- MAIN -------------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Web Tabs with Dropdowns',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

// ----------------- HOME PAGE -------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> imagePaths = const [
    'assets/images/photo_1.jpg',
    'assets/images/photo_2.jpg',
    'assets/images/photo_3.jpg',
    'assets/images/photo_4.jpg',
    'assets/images/photo_5.jpg',
  ];

  late Timer _timer;
  double _scrollSpeed = 1.0;
  Duration _tickDuration = const Duration(milliseconds: 10);

  // Keys
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _metricsKey = GlobalKey();
  final GlobalKey _personnelKey = GlobalKey();

  // Main widget
  Widget _selectedContentWidget = const Center(
    child: Text("Welcome! Select a tab.", style: TextStyle(fontSize: 20)),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(_tickDuration, (_) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double current = _scrollController.offset + _scrollSpeed;

        if (current >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(current);
        }
      }
    });
  }

  // ---------------- PDF Viewer ----------------
  Widget _pdfViewerFromGoogleDrive(String fileId) {
    String viewId = "iframe-${fileId.hashCode}";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://drive.google.com/file/d/$fileId/preview'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return HtmlElementView(viewType: viewId);
  }

  // ---------------- Excel Viewer ----------------
 // ---------------- Excel Viewer (Modified for scrollbars & clarity) ----------------
Widget _excelViewerFromGoogleDrive(String fileId) {
  String viewId = "excel-${fileId.hashCode}";

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = 'https://docs.google.com/spreadsheets/d/$fileId/htmlview'
      ..style.border = '1px solid #ccc'
      ..style.width = '2000px' // set a large width to allow horizontal scroll
      ..style.height = '800px' // set a fixed height
      ..style.overflow = 'auto'
      ..allowFullscreen = true;
    return iframe;
  });

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Container(
      width: 2000, // same as iframe width
      height: 800,
      child: HtmlElementView(viewType: viewId),
    ),
  );
}


  // ---------------- Looker Studio Dashboard ----------------
  Widget _lookerStudioDashboard(String embedUrl) {
    String viewId = "looker-${embedUrl.hashCode}";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }

  // ---------------- Power BI Dashboard ----------------
  Widget _powerBIDashboard(String embedUrl) {
    String viewId = "powerbi-${embedUrl.hashCode}";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: viewId),
    );
  }

  // ---------------- Dropdown Menu ----------------
  void _showDropdownMenu({
    required GlobalKey key,
    required List<String> items,
    required List<Color> colors,
  }) async {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: List.generate(items.length, (index) {
        double textWidth = items[index].length * 10.0;
        double containerWidth = textWidth.clamp(size.width, 250);

        return PopupMenuItem<String>(
          value: items[index],
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.all(8),
            color: colors[index],
            child: Text(items[index],
                style: const TextStyle(color: Colors.black)),
          ),
        );
      }),
    );

    if (selected != null) {
  setState(() {
    if (selected == "Organization Structure") {
      _selectedContentWidget =
          _pdfViewerFromGoogleDrive("14fWiw9XZ09JriNhudbtmaLNHpZzRRDdK");
    } else if (selected == "Rail Madad") {
      // Replaced charts with Looker Studio dashboard
      _selectedContentWidget = _lookerStudioDashboard(
        "https://lookerstudio.google.com/embed/reporting/cb98ba30-7af8-4d2f-ae2e-13e0388d0d44/page/p_cc5c1s4xwd",
      );
    } else if (selected == "Maintenance") {
      html.window.open(
          'https://roams.cris.org.in/cdmm/depotcurrentposition', '_blank');
      _selectedContentWidget = const Center(
        child: Text(
          "Opening Maintenance page in a new tab...",
          style: TextStyle(fontSize: 18),
        ),
      );
    } else if (selected == "WSP analysis") {
      _selectedContentWidget = _powerBIDashboard(
        "https://app.powerbi.com/view?r=eyJrIjoiN2Q3MjUzYzItMzc5ZC00ZTc2LWFiNjEtMTZmYzc1MmZjOGYyIiwidCI6ImYyZWY0NGZlLTk2YWUtNDZhNi1iMWI2LWIwOWE0NmZjMmYwZCJ9",
      );
    } else if (selected == "Modifications") {
      _selectedContentWidget = _excelViewerFromGoogleDrive(
        "1CBTnx3L-kPOU4nC_tCsKQ6Hbi7qjp8Pm", // <-- Replace with Excel file ID
      );
    } else {
      _selectedContentWidget = Center(
        child: Text("Content for $selected",
            style: const TextStyle(fontSize: 20)),
      );
    }
  });
}

  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------- Tab Button ----------------
  Widget _buildTabButton({
    required String title,
    required GlobalKey? key,
    required VoidCallback onPressed,
    Color textColor = Colors.blue,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TextButton(
        key: key,
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: textColor),
        child: Row(
          children: [
            Text(title, style: TextStyle(color: textColor, fontSize: 16)),
            if (key != null)
              const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double topHeight = MediaQuery.of(context).size.height * 0.25;
    List<String> displayImages = [...imagePaths, ...imagePaths];

    return Scaffold(
      body: Column(
        children: [
          // Top scrolling images
          SizedBox(
            height: topHeight,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  height: topHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(displayImages[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),

          // Tabs row
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTabButton(
                    key: _aboutKey,
                    title: "About",
                    onPressed: () {
                      setState(() {
                        _selectedContentWidget = const Center(
                          child: Text("Select an option from About",
                              style: TextStyle(fontSize: 20)),
                        );
                      });
                      _showDropdownMenu(
                        key: _aboutKey,
                        items: const ["Depot Overview", "Organization Structure"],
                        colors: [Colors.lightBlueAccent, Colors.greenAccent],
                      );
                    },
                  ),
                  _buildTabButton(
                    key: _metricsKey,
                    title: "Metrics",
                    onPressed: () {
                      setState(() {
                        _selectedContentWidget = const Center(
                          child: Text("Select an option from Metrics",
                              style: TextStyle(fontSize: 20)),
                        );
                      });
                      _showDropdownMenu(
                        key: _metricsKey,
                        items: const ["Modifications", "Rail Madad", "Maintenance", "WSP analysis"],
                        colors: [
                          Colors.redAccent,
                          Colors.orangeAccent,
                          Colors.purpleAccent,
                          Colors.greenAccent
                        ],
                      );
                    },
                  ),
                  _buildTabButton(
                    key: _personnelKey,
                    title: "Personnel",
                    onPressed: () {
                      setState(() {
                        _selectedContentWidget = const Center(
                          child: Text("Select an option from Personnel",
                              style: TextStyle(fontSize: 20)),
                        );
                      });
                      _showDropdownMenu(
                        key: _personnelKey,
                        items: const [
                          "DLT Complex",
                          "Rajdhani Complex",
                          "2290 Complex",
                          "Old Shatabdi Complex",
                          "Sick Line",
                          "Store",
                          "Linen"
                        ],
                        colors: [
                          Colors.pink,
                          Colors.orange,
                          Colors.purple,
                          Colors.yellow,
                          Colors.greenAccent,
                          Colors.cyanAccent,
                          Colors.blueAccent
                        ],
                      );
                    },
                  ),
                  _buildTabButton(
                    key: null,
                    title: "Circulars",
                    onPressed: () {
                      setState(() {
                        _selectedContentWidget = _lookerStudioDashboard(
                            "https://lookerstudio.google.com/embed/reporting/8e07a3d3-dd66-42a3-84ab-d54b22ba521a/page/p_hc6x9rgtbd");
                      });
                    },
                  ),
                  _buildTabButton(
                    key: null,
                    title: "Events",
                    onPressed: () {
                      setState(() {
                        _selectedContentWidget = const Center(
                          child: Text("Events Content",
                              style: TextStyle(fontSize: 20)),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(child: _selectedContentWidget),
        ],
      ),
    );
  }
}

// ---------------- DATA MODELS + FETCH ----------------
class ComplaintData {
  final String month;
  final int complaints;
  ComplaintData(this.month, this.complaints);
}

class ComplaintTypeData {
  final String type;
  final int count;
  ComplaintTypeData(this.type, this.count);
}

// Replace with your own Google Sheet details
const String sheetId = "1Po7DceaKOGvhbcEO4BA7UcQyscWILpGa74urTfXwGOk";
const String apiKey = "AIzaSyCaJcYBpeL7nx0JpXJFKrg4cTo6jGkl4gg";

/// Fetch Google Sheet data (Bar chart: A, B)
Future<List<ComplaintData>> fetchComplaintData({required String range}) async {
  final url =
      "https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/$range?key=$apiKey";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final values = data['values'] as List<dynamic>;

    if (values.isEmpty) return [];

    bool hasHeader = values.first[1].toString().trim().isNotEmpty &&
        int.tryParse(values.first[1].toString()) == null;

    final rows = hasHeader ? values.skip(1) : values;

    return rows.map((row) {
      return ComplaintData(
        row[0].toString(),
        int.tryParse(row[1].toString()) ?? 0,
      );
    }).toList();
  } else {
    throw Exception(
        "Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}");
  }
}

/// Fetch Google Sheet data (Pie chart: D, E)
Future<List<ComplaintTypeData>> fetchComplaintTypeData(
    {required String range}) async {
  final url =
      "https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/$range?key=$apiKey";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final values = data['values'] as List<dynamic>;

    if (values.isEmpty) return [];

    bool hasHeader = values.first[1].toString().trim().isNotEmpty &&
        int.tryParse(values.first[1].toString()) == null;

    final rows = hasHeader ? values.skip(1) : values;

    return rows.map((row) {
      return ComplaintTypeData(
        row[0].toString(),
        int.tryParse(row[1].toString()) ?? 0,
      );
    }).toList();
  } else {
    throw Exception(
        "Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}");
  }
}
