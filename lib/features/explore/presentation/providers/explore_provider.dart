import 'dart:async';

import 'package:flutter/foundation.dart';
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

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = ''; // '' = All
  String get selectedCategory => _selectedCategory;

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

  Future<void> fetchExploreUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _talents = await _repository.getExploreUsers(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
