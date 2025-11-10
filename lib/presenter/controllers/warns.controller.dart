import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/data/models/warns.model.dart';

class Warns extends StateNotifier<List<Warning>> {
  Warns() : super([]);

  Future<void> add(Warning warn, state) async {
    state = [...state, warn];
  }

  Future<void> remove(Warning warn, state) async {
    state = state.where((element) => element.id != warn.id).toList();
  }

  Future<void> update(Warning warn, state) async {
    state = state.map((element) {
      if (element.id == warn.id) {
        return warn;
      } else {
        return element;
      }
    }).toList();
  }
}

final warnsProvider = StateNotifierProvider<Warns, List<Warning>>((ref) {
  return Warns();
});

final hasNewAlertNotifier = StateProvider<bool>((ref) {
  return false;
});
