import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/data/services/emergency_contact.service.dart';
import 'package:rpa/presenter/widgets/emergency_contact_tile.dart';
import 'package:rpa/presenter/widgets/add_emergency_contact_dialog.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';

class EmergencyContactsScreen extends ConsumerStatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  ConsumerState<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends ConsumerState<EmergencyContactsScreen> {
  bool _isLoading = false;
  List<EmergencyContact> _contacts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(emergencyContactServiceProvider);
      final contacts = await service.getContacts(forceRefresh: true);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.emergencyContacts ?? 'Emergency Contacts'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewContact,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(AppLocalizations.of(context)?.add ?? 'Add'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadContacts,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildHeader(),
          if (_contacts.isEmpty) _buildEmptyState() else _buildContactsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Estes contatos receberão alertas automáticos quando você acionar o botão de emergência.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum contato adicionado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione contatos de confiança para situações de emergência',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    final priorityContacts = _contacts.where((c) => c.isPriority).toList();
    final regularContacts = _contacts.where((c) => !c.isPriority).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (priorityContacts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Contatos Prioritários (${priorityContacts.length}/5)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ...priorityContacts.map((contact) => EmergencyContactTile(
                contact: contact,
                onCall: () => _callContact(contact),
                onSMS: () => _sendSMS(contact),
                onEdit: () => _editContact(contact),
                onDelete: () => _deleteContact(contact),
              )),
        ],
        if (regularContacts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Outros Contatos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ...regularContacts.map((contact) => EmergencyContactTile(
                contact: contact,
                onCall: () => _callContact(contact),
                onSMS: () => _sendSMS(contact),
                onEdit: () => _editContact(contact),
                onDelete: () => _deleteContact(contact),
              )),
        ],
      ],
    );
  }

  Future<void> _callContact(EmergencyContact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível fazer a chamada')),
        );
      }
    }
  }

  Future<void> _sendSMS(EmergencyContact contact) async {
    final locationController = ref.read(locationControllerProvider);
    final position = locationController.currentPosition;

    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aguardando localização...')),
        );
      }
      return;
    }

    final message = '🚨 Estou em uma emergência!\n\n'
        'Minha localização: https://maps.google.com/?q=${position.latitude},${position.longitude}';

    final uri = Uri(
      scheme: 'sms',
      path: contact.phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível enviar SMS')),
        );
      }
    }
  }

  Future<void> _addNewContact() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddEmergencyContactDialog(),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);

      try {
        final service = ref.read(emergencyContactServiceProvider);
        await service.createContact(
          name: result['name'],
          phone: result['phone'],
          relation: result['relation'],
          isPriority: result['isPriority'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contato adicionado com sucesso!')),
          );
        }

        await _loadContacts();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editContact(EmergencyContact contact) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEmergencyContactDialog(contact: contact),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);

      try {
        final service = ref.read(emergencyContactServiceProvider);
        await service.updateContact(
          id: result['id'],
          name: result['name'],
          phone: result['phone'],
          relation: result['relation'],
          isPriority: result['isPriority'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contato atualizado com sucesso!')),
          );
        }

        await _loadContacts();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Contato'),
        content: Text('Tem certeza que deseja remover ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);

      try {
        final service = ref.read(emergencyContactServiceProvider);
        await service.deleteContact(contact.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contato removido com sucesso!')),
          );
        }

        await _loadContacts();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
        setState(() => _isLoading = false);
      }
    }
  }
}
