import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/models/safe_place.model.dart';
import 'package:rpa/data/services/safe_places.service.dart';
import 'package:rpa/presenter/pages/safe_places/widgets/add_safe_place_dialog.dart';
import 'package:unicons/unicons.dart';
import 'package:rpa/core/error/error_handler.dart';

final safePlacesListProvider = FutureProvider<List<SafePlace>>((ref) async {
  final service = ref.watch(safePlacesServiceProvider);
  await service.initialize();
  return service.getAllSafePlaces();
});

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  Future<void> _handleAddPlace(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<SafePlace>(
      context: context,
      builder: (context) => const AddSafePlaceDialog(),
    );

    if (result != null && context.mounted) {
      try {
        final service = ref.read(safePlacesServiceProvider);
        await service.createSafePlace(result);

        ref.invalidate(safePlacesListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} adicionado com sucesso!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _handleEditPlace(
    BuildContext context,
    WidgetRef ref,
    SafePlace place,
  ) async {
    final result = await showDialog<SafePlace>(
      context: context,
      builder: (context) => AddSafePlaceDialog(existingPlace: place),
    );

    if (result != null && context.mounted) {
      try {
        final service = ref.read(safePlacesServiceProvider);
        await service.updateSafePlace(result);

        ref.invalidate(safePlacesListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} atualizado!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _handleDeletePlace(
    BuildContext context,
    WidgetRef ref,
    SafePlace place,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Local'),
        content: Text('Deseja realmente excluir "${place.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(safePlacesServiceProvider);
        await service.deleteSafePlace(place.id);

        ref.invalidate(safePlacesListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${place.name} excluído'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safePlacesAsync = ref.watch(safePlacesListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Locais Salvos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: safePlacesAsync.when(
        data: (places) {
          if (places.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildPlaceCard(context, ref, place);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(ErrorHandler.getUserFriendlyMessage(error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(safePlacesListProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleAddPlace(context, ref),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_location_alt),
        label: const Text(
          'Adicionar Local',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                UniconsLine.map_marker_plus,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum Local Salvo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione locais seguros como casa de familiares, delegacias ou hospitais para acesso rápido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _handleAddPlace(context, ref),
              icon: const Icon(Icons.add_location_alt),
              label: const Text(
                'Adicionar Primeiro Local',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(
    BuildContext context,
    WidgetRef ref,
    SafePlace place,
  ) {
    final categoryColor = _getCategoryColor(place.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navegar para ${place.name}'),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      place.category.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.category.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (place.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          place.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _handleEditPlace(context, ref, place);
                    } else if (value == 'delete') {
                      _handleDeletePlace(context, ref, place);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(SafePlaceCategory category) {
    switch (category) {
      case SafePlaceCategory.home:
        return Colors.blue;
      case SafePlaceCategory.work:
        return Colors.purple;
      case SafePlaceCategory.policeStation:
        return Colors.blue;
      case SafePlaceCategory.hospital:
        return Colors.red;
      case SafePlaceCategory.fireStation:
        return Colors.orange;
      case SafePlaceCategory.family:
        return Colors.green;
      case SafePlaceCategory.friend:
        return Colors.teal;
      case SafePlaceCategory.other:
        return Colors.grey;
    }
  }
}
