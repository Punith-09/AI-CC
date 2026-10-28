import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:aicc/features/explore/data/repository/explore_repository.dart';

enum ExploreSortOption {
  firstToLast,
  lastToFirst,
  nameAtoZ,
  nameZtoA,
}

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

  // Sort
  ExploreSortOption _sortOption = ExploreSortOption.firstToLast;
  ExploreSortOption get sortOption => _sortOption;

  // Filters
  String filterDepartment = '';
  String filterGender = '';
  String filterAgeFrom = '';
  String filterAgeTo = '';
  String filterState = '';
  String filterCity = '';
  String filterLanguages = '';
  String filterCategories = '';
  String filterSkills = '';
  String filterHeightFrom = '';
  String filterHeightTo = '';
  String filterRole = '';
  String filterProjectType = '';

  bool get hasActiveFilters =>
      filterDepartment.isNotEmpty ||
      filterGender.isNotEmpty ||
      filterAgeFrom.isNotEmpty ||
      filterAgeTo.isNotEmpty ||
      filterState.isNotEmpty ||
      filterCity.isNotEmpty ||
      filterLanguages.isNotEmpty ||
      filterCategories.isNotEmpty ||
      filterSkills.isNotEmpty ||
      filterHeightFrom.isNotEmpty ||
      filterHeightTo.isNotEmpty ||
      filterRole.isNotEmpty ||
      filterProjectType.isNotEmpty;

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

  /// Called when the user selects a sort option.
  void onSortChanged(ExploreSortOption option) {
    _sortOption = option;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    switch (_sortOption) {
      case ExploreSortOption.firstToLast:
        // Original order, no change
        break;
      case ExploreSortOption.lastToFirst:
        _talents = _talents.reversed.toList();
        break;
      case ExploreSortOption.nameAtoZ:
        _talents.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ExploreSortOption.nameZtoA:
        _talents.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
  }

  void clearFilters() {
    _selectedCategory = '';
    filterDepartment = '';
    filterGender = '';
    filterAgeFrom = '';
    filterAgeTo = '';
    filterState = '';
    filterCity = '';
    filterLanguages = '';
    filterCategories = '';
    filterSkills = '';
    filterHeightFrom = '';
    filterHeightTo = '';
    filterRole = '';
    filterProjectType = '';
    fetchExploreUsers();
  }

  Future<void> fetchExploreUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final effectiveCategory = filterDepartment.isNotEmpty
          ? filterDepartment
          : (_selectedCategory.isEmpty ? null : _selectedCategory);

      final effectiveLocation = filterCity.isNotEmpty
          ? filterCity
          : (filterState.isNotEmpty
              ? filterState
              : (_selectedLocation.isEmpty || _selectedLocation == 'Anywhere'
                  ? null
                  : _selectedLocation));

      var results = await _repository.getExploreUsers(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        category: effectiveCategory,
        location: effectiveLocation,
      );

      // If backend returned nothing with location param, retry without location param
      // and let client-side profile matching filter by location!
      if (results.isEmpty && effectiveLocation != null) {
        results = await _repository.getExploreUsers(
          query: _searchQuery.isEmpty ? null : _searchQuery,
          category: effectiveCategory,
          location: null,
        );
      }

      // Filter out logged in user
      String? currentUserId;
      String? currentUserName;
      String? currentUserEmail;

      try {
        currentUserId = LocalStorage.instance.getUserId();
        currentUserName = LocalStorage.instance.getUserName();
        currentUserEmail = LocalStorage.instance.getUserEmail();
      } catch (_) {}

      final baseList = results.where((talent) {
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

      // Enrich talents with full public profile details (gender, age, location, skills, languages, height, role, projectType)
      final enrichedTalents = await _enrichTalents(baseList);

      final filteredResults = enrichedTalents.where((talent) {
        // 1. Filter by category / craft / department
        final targetCategory = filterDepartment.isNotEmpty
            ? filterDepartment
            : _selectedCategory;
        if (targetCategory.isNotEmpty && targetCategory != 'All') {
          if (!talent.matchesCategory(targetCategory)) {
            return false;
          }
        }

        // 2. Filter by gender
        if (filterGender.isNotEmpty) {
          if (!talent.matchesGender(filterGender)) {
            return false;
          }
        }

        // 3. Filter by age range
        if (filterAgeFrom.isNotEmpty || filterAgeTo.isNotEmpty) {
          if (!talent.matchesAge(filterAgeFrom, filterAgeTo)) {
            return false;
          }
        }

        // 4. Filter by categories (Film, Television, Web Series, etc.)
        if (filterCategories.isNotEmpty) {
          final target = filterCategories.toLowerCase();
          final inCat = talent.category.toLowerCase().contains(target);
          final inBio = talent.bio.toLowerCase().contains(target);
          final inProj = talent.projectType.toLowerCase().contains(target);
          if (!inCat && !inBio && !inProj) {
            return false;
          }
        }

        // 5. Filter by skills
        if (filterSkills.isNotEmpty) {
          if (!talent.matchesSkills(filterSkills)) {
            return false;
          }
        }

        // 6. Filter by languages
        if (filterLanguages.isNotEmpty) {
          if (!talent.matchesLanguage(filterLanguages)) {
            return false;
          }
        }

        // 7. Filter by height range
        if (filterHeightFrom.isNotEmpty || filterHeightTo.isNotEmpty) {
          if (!talent.matchesHeight(filterHeightFrom, filterHeightTo)) {
            return false;
          }
        }

        // 8. Filter by role
        if (filterRole.isNotEmpty) {
          if (!talent.matchesRole(filterRole)) {
            return false;
          }
        }

        // 9. Filter by project type
        if (filterProjectType.isNotEmpty) {
          if (!talent.matchesProjectType(filterProjectType)) {
            return false;
          }
        }

        // 10. Filter by location
        if (_selectedLocation.isNotEmpty && _selectedLocation != 'Anywhere') {
          if (!talent.matchesLocation(_selectedLocation)) {
            return false;
          }
        }
        if (filterCity.isNotEmpty) {
          if (!talent.matchesLocation(filterCity)) {
            return false;
          }
        }
        if (filterState.isNotEmpty) {
          if (!talent.matchesLocation(filterState)) {
            return false;
          }
        }

        return true;
      }).toList();

      _talents = filteredResults;
      _applySort();

      if (sl.isRegistered<ProfileProvider>()) {
        final profileProvider = sl<ProfileProvider>();
        for (int i = 0; i < _talents.length; i++) {
          final t = _talents[i];
          if (t.id.isNotEmpty) {
            if (t.explicitFollowing != null) {
              if (!profileProvider.isFollowLoading(t.id)) {
                profileProvider.recordFollowing(t.id, t.explicitFollowing!);
              }
            } else if (profileProvider.isFollowing(t.id)) {
              _talents[i] = t.copyWith(following: true);
            }
          }
        }
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<TalentModel>> _enrichTalents(List<TalentModel> talents) async {
    final futures = talents.map((talent) async {
      if (talent.id.isEmpty) return talent;

      final cached = _locationByUserId[talent.id];
      if (cached != null && (cached.hasCity || cached.gender.isNotEmpty || cached.skills.isNotEmpty || cached.languages.isNotEmpty)) {
        return cached;
      }

      try {
        final profile = await _repository.getUserPublicProfile(talent.id);
        final enriched = talent.copyWith(
          city: profile.city.isNotEmpty ? profile.city : talent.city,
          state: profile.state.isNotEmpty ? profile.state : talent.state,
          country: profile.country.isNotEmpty ? profile.country : talent.country,
          gender: profile.gender.isNotEmpty ? profile.gender : talent.gender,
          age: profile.age > 0 ? profile.age : talent.age,
          languages: profile.languages.isNotEmpty ? profile.languages : talent.languages,
          heightFt: profile.heightFt > 0 ? profile.heightFt : talent.heightFt,
          skills: profile.skills.isNotEmpty ? profile.skills : talent.skills,
          role: profile.role.isNotEmpty ? profile.role : talent.role,
          projectType: profile.projectType.isNotEmpty ? profile.projectType : talent.projectType,
        );
        _locationByUserId[talent.id] = enriched;
        return enriched;
      } catch (_) {
        return talent;
      }
    });

    return Future.wait(futures);
  }


  /// Clears state when the user logs out so the next user sees a fresh list.
  void clearForLogout() {
    _talents = [];
    _locationByUserId.clear();
    _searchQuery = '';
    _selectedCategory = '';
    _selectedLocation = 'Anywhere';
    _sortOption = ExploreSortOption.firstToLast;
    filterDepartment = '';
    filterGender = '';
    filterAgeFrom = '';
    filterAgeTo = '';
    filterState = '';
    filterCity = '';
    filterLanguages = '';
    filterCategories = '';
    filterSkills = '';
    filterHeightFrom = '';
    filterHeightTo = '';
    filterRole = '';
    filterProjectType = '';
    _isLoading = false;
    _error = null;
    _debounce?.cancel();
    _debounce = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
