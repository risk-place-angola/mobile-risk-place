import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/models/saved_address.dart';
import 'package:rpa/data/services/profile.service.dart';
import 'package:rpa/data/services/geocoding_service.dart';
import 'package:rpa/data/models/place_search_result.dart';

enum AddressType { home, work }

class SetAddressDialog extends ConsumerStatefulWidget {
  final AddressType addressType;
  final SavedAddress? currentAddress;

  const SetAddressDialog({
    super.key,
    required this.addressType,
    this.currentAddress,
  });

  @override
  ConsumerState<SetAddressDialog> createState() => _SetAddressDialogState();
}

class _SetAddressDialogState extends ConsumerState<SetAddressDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<PlaceSearchResult> _searchResults = [];
  PlaceSearchResult? _selectedPlace;
  bool _isSearching = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress != null) {
      _searchController.text = widget.currentAddress!.address;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final geocodingService = GeocodingService();
      final results = await geocodingService.searchPlaces(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = 'Erro ao buscar endereço';
      });
    }
  }

  void _selectPlace(PlaceSearchResult place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.displayName;
      _searchResults = [];
      _errorMessage = null;
    });
  }

  Future<void> _saveAddress() async {
    if (_selectedPlace == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione um endereço';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final profileService = ref.read(profileServiceProvider);
      final savedAddress = SavedAddress(
        name: widget.addressType == AddressType.home
            ? (AppLocalizations.of(context)?.home ?? 'Home')
            : (AppLocalizations.of(context)?.work ?? 'Work'),
        address: _selectedPlace!.displayName,
        latitude: _selectedPlace!.location.latitude,
        longitude: _selectedPlace!.location.longitude,
      );

      if (widget.addressType == AddressType.home) {
        await profileService.updateProfile(homeAddress: savedAddress);
      } else {
        await profileService.updateProfile(workAddress: savedAddress);
      }

      if (mounted) {
        Navigator.of(context).pop(savedAddress);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Erro ao salvar endereço: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.addressType == AddressType.home
        ? 'Configurar Casa'
        : 'Configurar Trabalho';
    final icon =
        widget.addressType == AddressType.home ? Icons.home : Icons.work;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar endereço...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _selectedPlace = null;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.length > 2) {
                    _searchPlaces(value);
                  }
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_isSearching) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(
                          result.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectPlace(result),
                      );
                    },
                  ),
                ),
              ],
              if (_selectedPlace != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selecionado: ${_selectedPlace!.displayName}',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
