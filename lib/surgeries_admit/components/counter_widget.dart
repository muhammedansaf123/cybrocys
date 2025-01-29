import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCircularCountDownTimer extends StatelessWidget {
  final int durationInSeconds;
  final int initialDuration;
  final CountDownController controller;

  final VoidCallback onComplete;
  final Function(String) onChange;
  final Map<String, dynamic> data;

  final int index;

  const CustomCircularCountDownTimer({
    Key? key,
    required this.durationInSeconds,
    required this.initialDuration,
    required this.controller,
    required this.onComplete,
    required this.onChange,
    required this.data,

    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
        duration: durationInSeconds,
        initialDuration: initialDuration,
        controller: controller,
        width: 100,
        height: 100,
        ringColor: Colors.grey[300]!,
        fillColor: Colors.purpleAccent[100]!,
        backgroundColor: Colors.deepPurple[500],
        strokeWidth: 4.0,
        strokeCap: StrokeCap.round,
        textStyle: const TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textFormat: CountdownTextFormat.HH_MM_SS,
        isReverse: false,
        isTimerTextShown: true,
        autoStart: true,
        onComplete: onComplete,
        onChange: onChange);
  }
}
