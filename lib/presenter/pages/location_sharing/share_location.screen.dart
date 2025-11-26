import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/models/location_sharing.model.dart';
import 'package:rpa/data/services/location_sharing.service.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/core/error/error_handler.dart';

class ShareLocationScreen extends ConsumerStatefulWidget {
  final LocationSharingSession session;
  final int durationMinutes;

  const ShareLocationScreen({
    super.key,
    required this.session,
    required this.durationMinutes,
  });

  @override
  ConsumerState<ShareLocationScreen> createState() =>
      _ShareLocationScreenState();
}

class _ShareLocationScreenState extends ConsumerState<ShareLocationScreen> {
  Timer? _updateTimer;
  Timer? _countdownTimer;
  late DateTime _expiresAt;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _expiresAt = widget.session.expiresAt;
    _calculateRemainingTime();
    _startLocationUpdates();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    _remainingSeconds = _expiresAt.difference(now).inSeconds;
    if (_remainingSeconds < 0) _remainingSeconds = 0;
  }

  void _startLocationUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _updateCurrentLocation();
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();
          if (_remainingSeconds <= 0) {
            _stopSharing();
          }
        });
      }
    });
  }

  Future<void> _updateCurrentLocation() async {
    try {
      final locationController = ref.read(locationControllerProvider);
      final position = locationController.currentPosition;

      if (position != null) {
        await ref.read(locationSharingServiceProvider).updateLocation(
              sessionId: widget.session.id,
              latitude: position.latitude,
              longitude: position.longitude,
            );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _stopSharing() async {
    try {
      await ref
          .read(locationSharingServiceProvider)
          .stopSharing(widget.session.id);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _shareLink() async {
    final l10n = AppLocalizations.of(context);
    final message = (l10n?.shareMessage ?? 'I\'m sharing my real-time location with you.\n\nAccess: {link}\n\nValid until: {expires}\n\nRiskPlace - Safer Cities 🛡️')
        .toString()
        .replaceAll('{link}', widget.session.shareLink)
        .replaceAll('{expires}', _formatDateTime(_expiresAt));
    
    await Share.share(
      message,
      subject: 'RiskPlace - Location Sharing',
    );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.session.shareLink));

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.linkCopied ?? 'Link copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatRemainingTime() {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final locationController = ref.watch(locationControllerProvider);
    final currentPosition = locationController.currentPosition;

    final l10n = AppLocalizations.of(context);
    
    if (currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.shareLocationTitle ?? 'Share Location'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final latLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.sharingLocationActive ?? 'Sharing Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n?.stopSharing ?? 'Stop Sharing'),
                  content: Text(
                    l10n?.stopSharingQuestion ?? 'Do you really want to stop sharing your location?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n?.cancel ?? 'Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n?.stopSharing ?? 'Stop'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _stopSharing();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share_location,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.activeSharing ?? 'Active Sharing',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (l10n?.expiresIn ?? 'Expires in: {time}').toString().replaceAll('{time}', _formatRemainingTime()),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareLink,
                        icon: const Icon(Icons.share),
                        label: Text(
                            AppLocalizations.of(context)?.share ?? 'Share'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyLink,
                        icon: const Icon(Icons.copy),
                        label: Text(AppLocalizations.of(context)?.copyLink ??
                            'Copy Link'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ao.riskplace.makanetu',
                  tileDisplay: TileDisplay.instantaneous(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng,
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.locationUpdating ?? 'Your location is being updated every 10 seconds',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _stopSharing,
                    icon: const Icon(Icons.stop),
                    label: Text(l10n?.stopSharing ?? 'Stop Sharing'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
