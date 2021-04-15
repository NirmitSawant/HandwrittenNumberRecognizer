import 'package:flutter/material.dart';
import 'package:handwritten_number_recognizer/brain.dart';
import 'package:handwritten_number_recognizer/constants.dart';
import 'package:handwritten_number_recognizer/drawing_painter.dart';
import 'package:fl_chart/fl_chart.dart';

class RecognizerScreen extends StatefulWidget {
  RecognizerScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RecognizerScreen createState() => _RecognizerScreen();
}

class _RecognizerScreen extends State<RecognizerScreen> {
  List<Offset> points = [];
  AppBrain brain = AppBrain();

  String headerText = 'Header placeholder';
  String footerText = 'Footer placeholder';

  List<BarChartGroupData> chartItems = [];

  void _buildBarChartInfo({List recognitions = const []}) {
    // Reset the list
    chartItems = [];

    // Create as many barGroups as outputs our prediction has
    for (var i = 0; i < 10; i++) {
      var barGroup = _makeGroupData(i, 0);
      chartItems.add(barGroup);
    }

    // For each one of our predictions, attach the probability
    // to the right index
    for (var recognition in recognitions) {
      final idx = recognition["index"];
      if (0 <= idx && idx <= 9) {
        final confidence = recognition["confidence"];
        chartItems[idx] = _makeGroupData(idx, confidence);
      }
    }
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        y: y,
        color: kBarColor,
        width: kChartBarWidth,
        isRound: true,
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          y: 1,
          color: kBarBackgroundColor,
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    brain.loadModel();
    _buildBarChartInfo();
    _resetLabels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cleanDrawing();
          _buildBarChartInfo();
        },
        tooltip: 'Clean',
        child: Icon(Icons.delete),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  headerText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  width: 3.0,
                  color: Colors.blue,
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (details) async {
                      points.add(null);
                      List predictions =
                          await brain.processCanvasPoints(points);
                      print(predictions);
                      setState(() {
                        _setLabelsForGuess(predictions.first['label']);
                        _buildBarChartInfo(recognitions: predictions);
                      });
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(kCanvasSize, kCanvasSize),
                        painter: DrawingPainter(
                          offsetPoints: points,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 32, 0, 64),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Center(
                        child: Text(
                          footerText,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 32, 32, 16),
                          child: BarChart(
                            BarChartData(
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                    showTitles: true,
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    margin: 6,
                                    getTitles: (double value) {
                                      return value.toInt().toString();
                                    }),
                                leftTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: chartItems,
                              // read about it in the below section
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cleanDrawing() {
    setState(() {
      points = [];
      _resetLabels();
    });
  }

  void _resetLabels() {
    headerText = kWaitingForInputHeaderString;
    footerText = kWaitingForInputFooterString;
  }

  void _setLabelsForGuess(String guess) {
    headerText = ""; // Empty string
    footerText = kGuessingInputString + guess;
  }
}
