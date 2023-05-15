import 'dart:developer';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rpa/core/utils/Utils.dart';
import 'package:rpa/presenter/controllers/alert.controller.dart';
import 'package:rpa/presenter/pages/home_page/widgets/alert_button.widget.dart';

class AlertPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends ConsumerState<AlertPage> {
  Position? _currentPosition;

  _getMyPosition() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    } else {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      print(_currentPosition!.latitude);
      print(_currentPosition!.longitude);
    }
  }

  @override
  void initState() {
    ref.read(alertProvider).init();
    _getMyPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(alertProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Alert Page'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Hero(
                    tag: "warning",
                    child: AlertButton(
                      icon: Icons.mic,
                      onPressed: () async {
                        provider.toogleRecord(context);
                        // var distance =
                        //     await Utils.getDistance(_currentPosition!);
                        // var distnceInKm = distance / 1000;
                        // var roundedDistance = distnceInKm.toStringAsFixed(2);
                      },
                    ),
                  ),
                ),
                Center(
                  child: AlertButton(
                    icon: provider.isPlaying
                        ? Icons.play_disabled
                        : Icons.play_arrow,
                    onPressed: () async {
                      provider.tooglePlay();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (provider.isRecording) ...[
              AudioWaveforms(
                  waveStyle: const WaveStyle(
                    extendWaveform: true,
                    showMiddleLine: true,
                    middleLineColor: Colors.transparent,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  size: Size(MediaQuery.of(context).size.width * 0.9, 40),
                  recorderController: provider.controller),
              Align(
                alignment: Alignment.centerRight,
                child: Text("${provider.controller.elapsedDuration}}"),
              )
            ],
            if (provider.isPlaying)
              AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width * 0.9, 100.0),
                playerController: provider.playerController,
                enableSeekGesture: true,
                waveformType: WaveformType.long,
                waveformData: [],
                playerWaveStyle: const PlayerWaveStyle(
                  fixedWaveColor: Colors.white54,
                  liveWaveColor: Colors.blueAccent,
                  spacing: 6,
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  var filePath = await FilePicker.platform.pickFiles(
                    onFileLoading: (p0) => log(p0.toString()),
                  );
                  if (filePath != null) print(filePath.paths.toString());
                },
                child: const Icon(Icons.folder_open),
              ),
            )
          ],
        ));
  }
}
