import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/services/settings.service.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/core/error/error_handler.dart';

class SafetySettingsScreen extends ConsumerStatefulWidget {
  const SafetySettingsScreen({super.key});

  @override
  ConsumerState<SafetySettingsScreen> createState() =>
      _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends ConsumerState<SafetySettingsScreen> {
  bool _isLoading = false;
  UserSettings? _settings;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final settingsService = ref.read(settingsServiceProvider);
      final settings = await settingsService.getSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = ErrorHandler.getUserFriendlyMessage(e, context);
        });
      }
    }
  }

  Future<void> _updateSetting(Map<String, dynamic> updates) async {
    if (_settings == null) return;

    try {
      final settingsService = ref.read(settingsServiceProvider);
      final updatedSettings = await settingsService.updateSettings(updates);
      if (mounted) {
        setState(() => _settings = updatedSettings);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n?.settingsUpdatedSuccess ??
                  'Configuração atualizada com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.safetySettings ?? 'Safety Settings')),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.errorLoadingSettings ?? 'Erro ao Carregar Configurações',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSettings,
                icon: const Icon(Icons.refresh),
                label: Text(l10n?.tryAgainButton ?? 'Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_settings == null) {
      return Center(
        child: Text(
            l10n?.noSettingsAvailable ?? 'Nenhuma configuração disponível'),
      );
    }

    return ListView(
      children: [
        _buildNotificationsSection(),
        _buildLocationSection(),
        _buildPrivacySection(),
        _buildAutoAlertsSection(),
        _buildNightModeSection(),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.notifications,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n?.notifications ?? 'Notifications',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n?.notificationsEnabled ?? 'Notifications Enabled'),
          subtitle: Text(
              l10n?.receiveAllNotifications ?? 'Receive all notifications'),
          value: _settings!.notificationsEnabled,
          onChanged: (value) => _updateSetting({'notificationsEnabled': value}),
        ),
        if (_settings!.notificationsEnabled) ...[
          ListTile(
            title: Text(l10n?.alertTypes ?? 'Alert Types'),
            subtitle: Text(_settings!.notificationAlertTypes.isEmpty
                ? (l10n?.noneSelected ?? 'None selected')
                : _settings!.notificationAlertTypes
                    .map((t) => t.getLocalizedName(l10n!))
                    .join(', ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAlertTypesDialog(),
          ),
          ListTile(
            title: Text(l10n?.alertRadius ?? 'Alert Radius'),
            subtitle: Text(
                '${(_settings!.notificationAlertRadiusMeters / 1000).toStringAsFixed(1)} km'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRadiusDialog(
              title: l10n?.alertRadius ?? 'Raio de Alerta',
              currentValue: _settings!.notificationAlertRadiusMeters,
              onSave: (value) =>
                  _updateSetting({'notificationAlertRadiusMeters': value}),
            ),
          ),
          ListTile(
            title: Text(l10n?.reportTypes ?? 'Report Types'),
            subtitle: Text(_settings!.notificationReportTypes.isEmpty
                ? (l10n?.noneSelected ?? 'None selected')
                : _settings!.notificationReportTypes
                    .map((t) => t.getLocalizedName(l10n!))
                    .join(', ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReportTypesDialog(),
          ),
          ListTile(
            title: Text(l10n?.reportRadius ?? 'Report Radius'),
            subtitle: Text(
                '${(_settings!.notificationReportRadiusMeters / 1000).toStringAsFixed(1)} km'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRadiusDialog(
              title: l10n?.reportRadius ?? 'Raio de Relatório',
              currentValue: _settings!.notificationReportRadiusMeters,
              onSave: (value) =>
                  _updateSetting({'notificationReportRadiusMeters': value}),
            ),
          ),
        ],
        const Divider(),
      ],
    );
  }

  Widget _buildLocationSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.location_on,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n?.tracking ?? 'Tracking',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n?.locationSharing ?? 'Location Sharing'),
          subtitle: Text(l10n?.shareLocationEmergencies ??
              'Share location in emergencies'),
          value: _settings!.locationSharingEnabled,
          onChanged: (value) =>
              _updateSetting({'locationSharingEnabled': value}),
        ),
        SwitchListTile(
          title: Text(l10n?.locationHistory ?? 'Location History'),
          subtitle: Text(l10n?.saveLocationHistory ??
              'Save history of where you\'ve been'),
          value: _settings!.locationHistoryEnabled,
          onChanged: (value) =>
              _updateSetting({'locationHistoryEnabled': value}),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPrivacySection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.security,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n?.privacy ?? 'Privacy',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n?.profileVisibility ?? 'Profile Visibility'),
          subtitle: Text(_settings!.profileVisibility.getLocalizedName(l10n!)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showProfileVisibilityDialog(),
        ),
        SwitchListTile(
          title: Text(l10n.anonymousReports),
          subtitle: Text(l10n.dontShowNameReports),
          value: _settings!.anonymousReports,
          onChanged: (value) => _updateSetting({'anonymousReports': value}),
        ),
        SwitchListTile(
          title: Text(l10n.showOnlineStatus),
          subtitle: Text(l10n.othersCanSeeOnline),
          value: _settings!.showOnlineStatus,
          onChanged: (value) => _updateSetting({'showOnlineStatus': value}),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildAutoAlertsSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.schedule,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n?.automaticAlertsSettings ?? 'Automatic Alerts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n?.automaticAlerts ?? 'Automatic Alerts'),
          subtitle: Text(l10n?.enableSmartAutomaticAlerts ??
              'Enable smart automatic alerts'),
          value: _settings!.autoAlertsEnabled,
          onChanged: (value) => _updateSetting({'autoAlertsEnabled': value}),
        ),
        SwitchListTile(
          title: Text(l10n?.dangerZones ?? 'Danger Zones'),
          subtitle: Text(l10n?.alertWhenEnteringRiskAreas ??
              'Alert when entering risk areas'),
          value: _settings!.dangerZonesEnabled,
          onChanged: (value) => _updateSetting({'dangerZonesEnabled': value}),
        ),
        SwitchListTile(
          title: Text(l10n?.timeBasedAlerts ?? 'Time-based Alerts'),
          subtitle: Text(l10n?.specialAlertsRiskTimes ??
              'Special alerts during risk times'),
          value: _settings!.timeBasedAlertsEnabled,
          onChanged: (value) =>
              _updateSetting({'timeBasedAlertsEnabled': value}),
        ),
        if (_settings!.timeBasedAlertsEnabled) ...[
          ListTile(
            title: Text(l10n?.startTime ?? 'Start Time'),
            subtitle: Text(_settings!.highRiskStartTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimePickerDialog(
              title: l10n?.startTime ?? 'Start Time',
              currentTime: _settings!.highRiskStartTime,
              onSave: (time) => _updateSetting({'highRiskStartTime': time}),
            ),
          ),
          ListTile(
            title: Text(l10n?.endTime ?? 'End Time'),
            subtitle: Text(_settings!.highRiskEndTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimePickerDialog(
              title: l10n?.endTime ?? 'End Time',
              currentTime: _settings!.highRiskEndTime,
              onSave: (time) => _updateSetting({'highRiskEndTime': time}),
            ),
          ),
        ],
        const Divider(),
      ],
    );
  }

  Widget _buildNightModeSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.nightlight_round,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n?.nightMode ?? 'Night Mode',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n?.automaticNightMode ?? 'Automatic Night Mode'),
          subtitle: Text(l10n?.enableAutomaticallyAtNight ??
              'Enable automatically at night'),
          value: _settings!.nightModeEnabled,
          onChanged: (value) => _updateSetting({'nightModeEnabled': value}),
        ),
        if (_settings!.nightModeEnabled) ...[
          ListTile(
            title: Text(l10n?.nightModeStart ?? 'Night Mode Start'),
            subtitle: Text(_settings!.nightModeStartTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimePickerDialog(
              title: l10n?.nightModeStart ?? 'Night Mode Start',
              currentTime: _settings!.nightModeStartTime,
              onSave: (time) => _updateSetting({'nightModeStartTime': time}),
            ),
          ),
          ListTile(
            title: Text(l10n?.nightModeEnd ?? 'Night Mode End'),
            subtitle: Text(_settings!.nightModeEndTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimePickerDialog(
              title: l10n?.nightModeEnd ?? 'Night Mode End',
              currentTime: _settings!.nightModeEndTime,
              onSave: (time) => _updateSetting({'nightModeEndTime': time}),
            ),
          ),
        ],
        const Divider(),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showAlertTypesDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final selected =
            List<AlertType>.from(_settings!.notificationAlertTypes);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n?.alertTypes ?? 'Alert Types'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AlertType.values.map((type) {
                  return CheckboxListTile(
                    title: Text(type.getLocalizedName(l10n!)),
                    value: selected.contains(type),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(type);
                        } else {
                          selected.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateSetting({'notificationAlertTypes': selected});
                    Navigator.pop(context);
                  },
                  child: Text(l10n?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportTypesDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final selected =
            List<ReportType>.from(_settings!.notificationReportTypes);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n?.reportTypes ?? 'Report Types'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ReportType.values.map((type) {
                  return CheckboxListTile(
                    title: Text(type.getLocalizedName(l10n!)),
                    value: selected.contains(type),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(type);
                        } else {
                          selected.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateSetting({'notificationReportTypes': selected});
                    Navigator.pop(context);
                  },
                  child: Text(l10n?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProfileVisibilityDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.profileVisibility ?? 'Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProfileVisibility.values.map((visibility) {
            return RadioListTile<ProfileVisibility>(
              title: Text(visibility.getLocalizedName(l10n!)),
              value: visibility,
              groupValue: _settings!.profileVisibility,
              onChanged: (value) {
                if (value != null) {
                  _updateSetting({'profileVisibility': value});
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRadiusDialog({
    required String title,
    required int currentValue,
    required Function(int) onSave,
  }) {
    final l10n = AppLocalizations.of(context);
    double sliderValue = currentValue.toDouble();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(sliderValue / 1000).toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: sliderValue,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  label: '${(sliderValue / 1000).toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() => sliderValue = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n?.cancel ?? 'Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  onSave(sliderValue.toInt());
                  Navigator.pop(context);
                },
                child: Text(l10n?.save ?? 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTimePickerDialog({
    required String title,
    required String currentTime,
    required Function(String) onSave,
  }) {
    final parts = currentTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return child!;
      },
    ).then((time) {
      if (time != null) {
        final timeString =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        onSave(timeString);
      }
    });
  }
}
