import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:aicc/features/explore/data/repository/explore_repository.dart';

class ExploreProvider with ChangeNotifier {
  final ExploreRepository _repository;

  ExploreProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<TalentModel> _talents = [];
  List<TalentModel> get talents => _talents;

  final Map<String, TalentModel> _locationByUserId = {};

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = ''; // '' = All
  String get selectedCategory => _selectedCategory;

  String _selectedLocation = 'Anywhere';
  String get selectedLocation => _selectedLocation;

  // Debounce timer for search
  Timer? _debounce;

  /// Called when the user types in the search bar.
  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchExploreUsers();
    });
  }

  /// Called when the user taps a category chip.
  void onCategoryChanged(String category) {
    // 'All' resets the filter
    _selectedCategory = (category == 'All' || category.isEmpty) ? '' : category;
    fetchExploreUsers();
  }

  /// Called when the user selects a new location.
  void onLocationChanged(String location) {
    _selectedLocation = location;
    fetchExploreUsers();
  }

  Future<void> fetchExploreUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _repository.getExploreUsers(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );

      // Filter out logged in user
      String? currentUserId;
      String? currentUserName;
      String? currentUserEmail;

      try {
        currentUserId = LocalStorage.instance.getUserId();
        currentUserName = LocalStorage.instance.getUserName();
        currentUserEmail = LocalStorage.instance.getUserEmail();
      } catch (_) {}

      final filteredResults = results.where((talent) {
        if (currentUserId != null &&
            currentUserId.isNotEmpty &&
            talent.id == currentUserId) {
          return false;
        }
        if (currentUserName != null &&
            currentUserName.isNotEmpty &&
            talent.name.trim().toLowerCase() ==
                currentUserName.trim().toLowerCase()) {
          return false;
        }
        if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
          final emailPrefix =
              currentUserEmail.split('@').first.trim().toLowerCase();
          if (talent.name.trim().toLowerCase() == emailPrefix ||
              talent.handle
                  .replaceAll('@', '')
                  .trim()
                  .toLowerCase() ==
                  emailPrefix) {
            return false;
          }
        }
        return true;
      }).toList();

      final needsLocation =
          _selectedLocation.isNotEmpty && _selectedLocation != 'Anywhere';
      final withLocation =
          needsLocation ? await _attachLocations(filteredResults) : filteredResults;
      _talents = _applyLocationFilter(withLocation);
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<TalentModel>> _attachLocations(List<TalentModel> talents) async {
    final futures = talents.map((talent) async {
      final cached = _locationByUserId[talent.id];
      if (cached != null && cached.hasCity) {
        return talent.copyWith(
          city: cached.city,
          state: cached.state,
          country: cached.country,
        );
      }

      if (talent.id.isEmpty) return talent;

      try {
        final profile = await _repository.getUserPublicProfile(talent.id);
        final city = profile.city.isNotEmpty ? profile.city : talent.city;
        final state = profile.state.isNotEmpty ? profile.state : talent.state;
        final country =
            profile.country.isNotEmpty ? profile.country : talent.country;
        final enriched = talent.copyWith(
          city: city,
          state: state,
          country: country,
        );
        _locationByUserId[talent.id] = enriched;
        return enriched;
      } catch (_) {
        return talent;
      }
    });

    return Future.wait(futures);
  }

  List<TalentModel> _applyLocationFilter(List<TalentModel> talents) {
    if (_selectedLocation.isEmpty || _selectedLocation == 'Anywhere') {
      return talents;
    }
    return talents
        .where((talent) => talent.matchesLocation(_selectedLocation))
        .toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
