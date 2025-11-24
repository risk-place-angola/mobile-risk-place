import 'package:animate_gradient/animate_gradient.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:rpa/core/utils/datetime_helper.dart';
import 'package:rpa/data/models/warns.model.dart';
import 'package:rpa/presenter/controllers/home.controller.dart';
import 'package:rpa/presenter/controllers/warns.controller.dart';

class AlertsList extends ConsumerWidget {
  final List<Warning>? warns;
  
  const AlertsList({super.key, this.warns});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var hasNewAlert = ref.watch(hasNewAlertNotifier.notifier).state;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasNewAlert) ...[
            Expanded(
              flex: 1,
              child: NewAlert(),
            ),
          ] else ...[
            Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: warns!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(warns![index].reportedBy!),
                        subtitle:
                            Text(warns![index].createdAt!.toFormatString()),
                        trailing: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alert deletion will be available in a future update'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    );
                  }),
            ),
          ]
        ],
      ),
    );
  }
}

class NewAlert extends ConsumerWidget {
  final PlayerController _playController = PlayerController();

  NewAlert({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final controller = MapController();
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: AnimateGradient(
        duration: const Duration(seconds: 1),
        reverse: true,
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomCenter,
        secondaryBegin: Alignment.bottomCenter,
        secondaryEnd: Alignment.topLeft,
        primaryColors: [secondary, secondary, primary],
        secondaryColors: [primary, secondary, primary.withOpacity(0.8)],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.10,
              bottom: MediaQuery.of(context).size.height * 0.05,
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Alerta",
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: FlutterMap(
                        mapController: controller,
                        options: MapOptions(
                          onMapReady: () {},
                          initialCenter: ll.LatLng(-8.852845, 13.265561),
                          initialZoom: 16.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName: 'ao.riskplace.makanetu',
                            tileDisplay: TileDisplay.instantaneous(),
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 100.0,
                                height: 100.0,
                                point: ll.LatLng(-8.852845, 13.265561),
                                child: Icon(
                                  Icons.person_pin_circle,
                                  size: 50.0,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        child: Row(
                      children: [
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: primary,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // _playController
                                  //   ..preparePlayer(path: path)
                                  //   ..startPlayer();
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AudioFileWaveforms(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            size: Size(
                                MediaQuery.of(context).size.width * 0.85, 55),
                            playerController: _playController,
                            enableSeekGesture: true,
                            waveformType: WaveformType.long,
                            waveformData: [],
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.transparent,
                              liveWaveColor: Colors.blueAccent,
                              spacing: 6,
                            ),
                          ),
                        ),
                      ],
                    )),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.85, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () {
                          ref.read(homeProvider).setNewAlert(ref);
                        },
                        child: Text(
                          "Indo para o local",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
