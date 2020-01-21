import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'RRectPainter.dart';
import 'Splash.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class DigiLogClock extends StatefulWidget {
  const DigiLogClock(this.model);

  final ClockModel model;

  @override
  _DigiLogClockState createState() => _DigiLogClockState();
}

class _DigiLogClockState extends State<DigiLogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    //setting preferred orientation to Landscape
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);
    // removing UI Overlays
    SystemChrome.setEnabledSystemUIOverlays([]);
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigiLogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Colors.blue,
            // Minute hand.
            highlightColor: Colors.red,
            // Second hand.
            accentColor: Color(0xFF05C42D),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Colors.blue,
            highlightColor: Colors.red,
            accentColor: Color(0xFF05C42D),
            backgroundColor: Color(0xFF3C4043),
          );

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );
    // variables used to show time.
    String hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_now);
    String min = DateFormat('mm').format(_now);
    String sec = DateFormat('ss').format(_now);
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Digilog Clock with time $hour:$min:$sec',
        value: "$hour:$min:$sec",
      ),
      child: Container(
        child: Stack(
          children: [
            //The Hour's RRect
            // will rotate every hour
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Transform.rotate(
                angle: _now.hour * radiansPerHour +
                    (_now.minute / 60) * radiansPerHour,
                child: Center(
                  child: CustomPaint(
                      painter: RRectPainter(
                        cornerRadius: 50,
                        strokeWidth: 4,
                        baseColor: customTheme.primaryColor,
                      ),
                      size: MediaQuery.of(context).size - Offset(105, 105)),
                ),
              ),
            ),
            //The Minutes's RRect
            // will rotate every minute
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Transform.rotate(
                angle: _now.minute * radiansPerTick,
                child: Center(
                  child: CustomPaint(
                      painter: RRectPainter(
                        cornerRadius: 30,
                        strokeWidth: 3,
                        baseColor: customTheme.highlightColor,
                      ),
                      size: MediaQuery.of(context).size - Offset(170, 170)),
                ),
              ),
            ),
// Digital Time at the center of the clock.
            Center(
              child: Container(
                color: Colors.transparent,
                child: RichText(
                  text: TextSpan(
                      text: "$hour",
                      children: [
                        TextSpan(
                            text: ":$min",
                            style: TextStyle(color: customTheme.primaryColor)),
                        TextSpan(
                            text: ":$sec",
                            style: TextStyle(color: customTheme.accentColor)),
                      ],
                      style: TextStyle(
                          fontSize: 25,
                          color: customTheme.highlightColor,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: weatherInfo,
              ),
            ),
            // Splashes every second
            Splash(
              color: customTheme.accentColor,
              size: 200,
              key: Key("secondsSplash"),
            ),
          ],
        ),
      ),
    );
  }
}
