import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/enums.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service);

  final IncidentService _service;
  StreamSubscription<List<Incident>>? _subscription;

  String? _boundUid;
  String? _uid;
  List<Incident> _all = [];
  bool _loading = false;
  String? _error;

  String _query = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;
  bool _mineOnly = false;

  List<Incident> get all => _all;
  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;
  bool get mineOnly => _mineOnly;

  List<Incident> get mine =>
      _all.where((incident) => incident.reporterId == _uid).toList();

  List<Incident> get filtered {
    final text = _query.trim().toLowerCase();
    return _all.where((incident) {
      if (_mineOnly && incident.reporterId != _uid) return false;
      if (_statusFilter != null && incident.status != _statusFilter) {
        return false;
      }
      if (_categoryFilter != null && incident.category != _categoryFilter) {
        return false;
      }
      if (text.isEmpty) return true;
      return incident.title.toLowerCase().contains(text) ||
          incident.description.toLowerCase().contains(text) ||
          incident.location.toLowerCase().contains(text) ||
          incident.category.label.toLowerCase().contains(text);
    }).toList();
  }

  bool get hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _statusFilter != null ||
      _categoryFilter != null ||
      _mineOnly;

  void bind(AppUser? user) {
    _uid = user?.uid;
    if (user?.uid == _boundUid) return;

    _subscription?.cancel();
    _subscription = null;
    _boundUid = user?.uid;
    _all = [];
    _error = null;
    _query = '';
    _statusFilter = null;
    _categoryFilter = null;
    _mineOnly = false;

    if (user == null) {
      _loading = false;
      return;
    }

    _loading = true;
    _subscription = _service.watchAll().listen(
      (items) {
        _all = items;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _error = 'Unable to load reports. Check your connection.';
        notifyListeners();
      },
    );
  }

  Incident? byId(String id) {
    for (final incident in _all) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  int count(IncidentStatus? status, {bool mineOnly = false}) {
    return _all.where((incident) {
      if (mineOnly && incident.reporterId != _uid) return false;
      return status == null || incident.status == status;
    }).length;
  }

  int countCategory(IncidentCategory category) =>
      _all.where((incident) => incident.category == category).length;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setMineOnly(bool value) {
    _mineOnly = value;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _statusFilter = null;
    _categoryFilter = null;
    _mineOnly = false;
    notifyListeners();
  }

  Future<void> submit({
    required AppUser reporter,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    final incident = Incident(
      id: _service.newId(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      location: location,
      status: IncidentStatus.submitted,
      imageUrl: imageUrl,
      reporterId: reporter.uid,
      reporterName: reporter.name,
      createdAt: now,
      updatedAt: now,
      history: [
        StatusEntry(
          status: IncidentStatus.submitted,
          at: now,
          by: reporter.name,
        ),
      ],
    );
    return _service.create(incident);
  }

  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    required String staffName,
  }) {
    return _service.updateStatus(
      incidentId: incidentId,
      status: status,
      staffName: staffName,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}