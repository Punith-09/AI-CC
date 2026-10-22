import 'package:flutter/material.dart';

import '../../data/datasource/live_stats_remote_datasource.dart';
import '../../data/models/live_stats_model.dart';

class LiveStatsProvider extends ChangeNotifier {
  final LiveStatsRemoteDataSource _dataSource;

  LiveStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  LiveStatsProvider(this._dataSource);

  LiveStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _stats = await _dataSource.getStats();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
