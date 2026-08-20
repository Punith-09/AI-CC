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

  Future<void> fetchExploreUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _talents = await _repository.getExploreUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
