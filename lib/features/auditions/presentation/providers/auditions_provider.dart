import 'package:flutter/material.dart';
import '../../data/models/audition_model.dart';
import '../../data/models/create_audition_request.dart';
import '../../data/repository/auditions_repository.dart';

class AuditionsProvider extends ChangeNotifier {
  final AuditionsRepository _auditionsRepository;

  AuditionsProvider(this._auditionsRepository);

  List<AuditionModel> _auditions = [];
  bool _isLoading = false;
  String? _errorMessage;

  AuditionModel? _selectedAudition;
  bool _isDetailLoading = false;
  String? _detailErrorMessage;

  bool _isCreateLoading = false;
  String? _createErrorMessage;

  List<AuditionModel> get auditions => _auditions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuditionModel? get selectedAudition => _selectedAudition;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailErrorMessage => _detailErrorMessage;

  bool get isCreateLoading => _isCreateLoading;
  String? get createErrorMessage => _createErrorMessage;

  Future<void> fetchAuditions({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _auditions = await _auditionsRepository.getAuditions(category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<AuditionModel?> fetchAuditionById(String id, {AuditionModel? initialData}) async {
    _selectedAudition = initialData;
    _isDetailLoading = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      final audition = await _auditionsRepository.getAuditionById(id);
      _selectedAudition = audition;
      _isDetailLoading = false;
      notifyListeners();
      return audition;
    } catch (e) {
      _isDetailLoading = false;
      _detailErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return _selectedAudition;
    }
  }

  Future<bool> createAudition(CreateAuditionRequest request) async {
    _isCreateLoading = true;
    _createErrorMessage = null;
    notifyListeners();

    try {
      final newAudition = await _auditionsRepository.createAudition(request);
      _auditions.insert(0, newAudition);
      _isCreateLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCreateLoading = false;
      _createErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearSelectedAudition() {
    _selectedAudition = null;
    _detailErrorMessage = null;
    notifyListeners();
  }
}
