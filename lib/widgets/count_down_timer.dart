import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/vpn_engine.dart';

class TimerController extends GetxController {
  late Timer _timer;
  Duration _duration = Duration();
  bool _isTimerRunning = false;

  void startTimer() {
    if (!_isTimerRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _duration += Duration(seconds: 1);
        update();
      });
      _isTimerRunning = true;
    }
  }

  void stopTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
      _isTimerRunning = false;
      _duration = Duration(); // Reset duration to zero
      update();
    }
  }

  String getFormattedTime() {
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigit(_duration.inMinutes.remainder(60));
    final seconds = twoDigit(_duration.inSeconds.remainder(60));
    final hours = twoDigit(_duration.inHours.remainder(60));

    return '$hours: $minutes: $seconds';
  }

  @override
  void onClose() {
    super.onClose();
    _timer.cancel();
  }
}

class CountDownTimer extends StatefulWidget {
  final Rx<String> vpnState;

  const CountDownTimer({Key? key, required this.vpnState}) : super(key: key);

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  final TimerController timerController = Get.put(TimerController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.vpnState.value == VpnEngine.vpnConnected) {
        timerController.startTimer();
      } else {
        timerController.stopTimer();
      }

      return GetBuilder<TimerController>(
        builder: (_) {
          return Text(
            timerController.getFormattedTime(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF777777),
            ),
          );
        },
      );
    });
  }
}
