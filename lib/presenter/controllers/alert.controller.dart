// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/models/warns.model.dart';
import 'package:rpa/data/services/warn.service.dart';

final alertProvider = ChangeNotifierProvider((ref) => AlertController());

class AlertController extends ChangeNotifier {
  User? user;

  init() async {
    user = await UserBox().getUser();
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    notifyListeners();
  }

  Position? _currentPosition;
  WarnService _warnService = WarnService();
  var lastRecordedPath = "";
  RecorderController controller = RecorderController();
  PlayerController playerController = PlayerController();
  bool isRecording = false;
  bool isPlaying = false;
  int recordTime = 0;

  void tooglePlay() async {
    await playerController.preparePlayer(
      path: lastRecordedPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    isPlaying = !isPlaying;

    isPlaying
        ? await playerController.startPlayer()
        : await playerController.stopPlayer();
    notifyListeners();
  }

  void toogleRecord(BuildContext context) async {
    var file;
    isRecording = !isRecording;
    isRecording
        ? await controller.record(
            sampleRate: 44100,
            bitRate: 192000,
            androidEncoder: AndroidEncoder.aac,
            androidOutputFormat: AndroidOutputFormat.mpeg4)
        : file = await controller.stop();

    if (file != null) lastRecordedPath = file;
    File storagedFile = File(lastRecordedPath);
    if (storagedFile.existsSync()) {
      Warning warning = Warning(
          createdAt: DateTime.now(),
          isVictim: true,
          reportedBy: user!.id,
          additionalData: storagedFile,
          location: {
            "latitude": _currentPosition!.latitude.toString(),
            "longitude": _currentPosition!.longitude.toString(),
          });
      sendWarning(context, warning: warning);
    } else {
      print("File not exists");
    }

    notifyListeners();
  }

  void sendWarning(BuildContext context, {Warning? warning}) async {
    var response = await _warnService.createWarning(warning!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
    ));
  }
}

DatabaseReference warnsStream =
    FirebaseDatabase.instance.ref(BDCollections.WARNINGS);
