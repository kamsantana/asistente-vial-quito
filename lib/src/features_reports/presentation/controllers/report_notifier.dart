import 'package:flutter/material.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/usecases/get_smart_reports_usecase.dart';

enum ReportState { initial, loading, loaded, error }

class ReportNotifier extends ChangeNotifier {
  final GetSmartReportsUseCase _getSmartReportsUseCase;

  ReportNotifier(this._getSmartReportsUseCase);

  ReportState _state = ReportState.initial;
  ReportState get state => _state;

  List<ReportEntity> _reports = [];
  List<ReportEntity> get reports => _reports;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadReports() async {
    _state = ReportState.loading;
    notifyListeners();

    try {
      _reports = await _getSmartReportsUseCase.call();
      _state = ReportState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ReportState.error;
    }
    notifyListeners();
  }
}
