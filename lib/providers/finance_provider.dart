import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/finance.dart';

class FinanceProvider with ChangeNotifier {
  List<RevenueReport> _revenueReports = [];
  List<PerformanceMetrics> _performanceMetrics = [];
  bool _isLoading = false;
  String? _error;

  List<RevenueReport> get revenueReports => _revenueReports;
  List<PerformanceMetrics> get performanceMetrics => _performanceMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRevenueReports(String teamId) async {
    print('🔍 [DEBUG] fetchRevenueReports called with teamId: $teamId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      print('🔍 [DEBUG] Querying RevenueReport collection for teamId: $teamId');
      
      final querySnapshot = await firestore
          .collection('RevenueReport')
          .where('teamId', isEqualTo: teamId)
          .orderBy('reportDate', descending: true)
          .get();

      print('🔍 [DEBUG] RevenueReport query completed. Found ${querySnapshot.docs.length} documents');
      
      _revenueReports = querySnapshot.docs.map((doc) {
        print('🔍 [DEBUG] Processing document: ${doc.id}');
        print('🔍 [DEBUG] Document data: ${doc.data()}');
        return RevenueReport.fromJson(doc.data());
      }).toList();
      
      print('🔍 [DEBUG] Parsed ${_revenueReports.length} revenue reports');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load revenue reports: $e');
      _error = 'Failed to load revenue reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPerformanceMetrics(String teamId) async {
    print('🔍 [DEBUG] fetchPerformanceMetrics called with teamId: $teamId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      print('🔍 [DEBUG] Querying perfMetrics collection for teamId: $teamId');
      
      final querySnapshot = await firestore
          .collection('perfMetrics')
          .where('teamId', isEqualTo: teamId)
          .orderBy('season', descending: true)
          .get();

      print('🔍 [DEBUG] perfMetrics query completed. Found ${querySnapshot.docs.length} documents');

      _performanceMetrics = querySnapshot.docs.map((doc) {
        print('🔍 [DEBUG] Processing performance document: ${doc.id}');
        print('🔍 [DEBUG] Performance document data: ${doc.data()}');
        return PerformanceMetrics.fromJson(doc.data());
      }).toList();
      
      print('🔍 [DEBUG] Parsed ${_performanceMetrics.length} performance metrics');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load performance metrics: $e');
      _error = 'Failed to load performance metrics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllFinancialData() async {
    print('🔍 [DEBUG] fetchAllFinancialData called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Fetch revenue reports
      print('🔍 [DEBUG] Fetching all RevenueReport documents');
      final revenueSnapshot = await firestore
          .collection('RevenueReport')
          .orderBy('reportDate', descending: true)
          .get();

      print('🔍 [DEBUG] Found ${revenueSnapshot.docs.length} revenue reports');

      // Fetch performance metrics
      print('🔍 [DEBUG] Fetching all perfMetrics documents');
      final metricsSnapshot = await firestore
          .collection('perfMetrics')
          .orderBy('season', descending: true)
          .get();

      print('🔍 [DEBUG] Found ${metricsSnapshot.docs.length} performance metrics');

      _revenueReports = revenueSnapshot.docs
          .map((doc) => RevenueReport.fromJson(doc.data()))
          .toList();

      _performanceMetrics = metricsSnapshot.docs
          .map((doc) => PerformanceMetrics.fromJson(doc.data()))
          .toList();
      
      print('🔍 [DEBUG] Total revenue reports: ${_revenueReports.length}');
      print('🔍 [DEBUG] Total performance metrics: ${_performanceMetrics.length}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [ERROR] Failed to load financial data: $e');
      _error = 'Failed to load financial data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<RevenueReport> getRevenueReportsByTeam(String teamId) {
    print('🔍 [DEBUG] getRevenueReportsByTeam called with teamId: $teamId');
    final reports = _revenueReports.where((report) => report.teamId == teamId).toList();
    print('🔍 [DEBUG] Found ${reports.length} reports for teamId: $teamId');
    return reports;
  }

  List<RevenueReport> getRevenueReportsByYear(int year) {
    return _revenueReports.where((report) => report.year == year).toList();
  }

  List<RevenueReport> getRevenueReportsByQuarter(Quarter quarter) {
    return _revenueReports.where((report) => report.quarter == quarter).toList();
  }

  PerformanceMetrics? getPerformanceMetricsByTeamAndSeason(String teamId, int season) {
    try {
      return _performanceMetrics.firstWhere(
        (metrics) => metrics.teamId == teamId && metrics.season == season,
      );
    } catch (e) {
      return null;
    }
  }

  List<PerformanceMetrics> getPerformanceMetricsByTeam(String teamId) {
    print('🔍 [DEBUG] getPerformanceMetricsByTeam called with teamId: $teamId');
    final metrics = _performanceMetrics.where((metrics) => metrics.teamId == teamId).toList();
    print('🔍 [DEBUG] Found ${metrics.length} performance metrics for teamId: $teamId');
    return metrics;
  }

  double getTotalRevenueByTeam(String teamId, int year) {
    return getRevenueReportsByTeam(teamId)
        .where((report) => report.year == year)
        .fold(0.0, (sum, report) => sum + report.totalRevenue);
  }

  double getAverageRevenueByTeam(String teamId) {
    final reports = getRevenueReportsByTeam(teamId);
    if (reports.isEmpty) return 0.0;
    
    final totalRevenue = reports.fold(0.0, (sum, report) => sum + report.totalRevenue);
    return totalRevenue / reports.length;
  }

  Map<RevenueType, double> getRevenueBreakdownByTeam(String teamId, int year) {
    final reports = getRevenueReportsByTeam(teamId).where((report) => report.year == year);
    final breakdown = <RevenueType, double>{};
    
    for (final report in reports) {
      for (final entry in report.revenueByType.entries) {
        breakdown[entry.key] = (breakdown[entry.key] ?? 0.0) + entry.value;
      }
    }
    
    return breakdown;
  }

  double getRevenueGrowthByTeam(String teamId) {
    final reports = getRevenueReportsByTeam(teamId);
    if (reports.length < 2) return 0.0;
    
    // Sort by date and get the two most recent reports
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    final latest = reports[0];
    final previous = reports[1];
    
    if (previous.totalRevenue > 0) {
      return ((latest.totalRevenue - previous.totalRevenue) / previous.totalRevenue) * 100;
    }
    return 0.0;
  }

  Future<void> addRevenueReport(RevenueReport report) async {
    try {
      // Add to Firebase
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('RevenueReport').add(report.toJson());
      
      // Add to local state
      _revenueReports.add(report);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add revenue report: $e';
      notifyListeners();
    }
  }

  Future<void> addPerformanceMetrics(PerformanceMetrics metrics) async {
    try {
      // Add to Firebase
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('perfMetrics').add(metrics.toJson());
      
      // Add to local state
      _performanceMetrics.add(metrics);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add performance metrics: $e';
      notifyListeners();
    }
  }

  void reset() {
    _revenueReports = [];
    _performanceMetrics = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
} 