import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/data/services/geocoding_service.dart';
import 'package:rpa/data/models/place_search_result.dart';
import 'package:rpa/core/error/error_handler.dart';

class SearchDestinationScreen extends StatefulWidget {
  final LatLng? origin;

  const SearchDestinationScreen({
    super.key,
    this.origin,
  });

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<PlaceSearchResult> _searchResults = [];
  LatLng? _selectedDestination;
  bool _isSearching = false;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.origin;
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
      final results =
          await geocodingService.searchPlaces(query, countryCode: 'ao');

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  void _selectPlace(PlaceSearchResult place) {
    setState(() {
      _selectedDestination = place.location;
      _searchController.text = place.displayName;
      _searchResults = [];
      _showMap = false;
    });
  }

  void _selectFromMap() {
    setState(() => _showMap = true);
  }

  void _confirmDestination() {
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um destino')),
      );
      return;
    }

    Navigator.of(context).pop(_selectedDestination);
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = widget.origin ?? const LatLng(-8.8383, 13.2344);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Destino'),
        actions: [
          if (_selectedDestination != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmDestination,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar endereço ou local...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _selectedDestination = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchPlaces,
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (_searchResults.isNotEmpty && !_showMap)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(result.name),
                    subtitle: Text(result.displayName),
                    onTap: () => _selectPlace(result),
                  );
                },
              ),
            ),
          if (!_showMap && _searchResults.isEmpty && !_isSearching)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Busque um endereço ou\nselecione no mapa',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectFromMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Selecionar no Mapa'),
                    ),
                  ],
                ),
              ),
            ),
          if (_showMap)
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentPosition,
                      initialZoom: 13.0,
                      onTap: (_, position) {
                        setState(() => _selectedDestination = position);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'ao.riskplace.makanetu',
                        tileDisplay: TileDisplay.instantaneous(),
                      ),
                      if (_selectedDestination != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedDestination!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _confirmDestination,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Confirmar Destino'),
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
