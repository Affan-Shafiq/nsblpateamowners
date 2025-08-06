import 'package:cloud_firestore/cloud_firestore.dart';

enum RevenueType { merchandise, sponsorship, media, other }
enum Quarter { q1, q2, q3, q4 }

class RevenueReport {
  final String teamId;
  final Quarter quarter;
  final int year;
  final Map<RevenueType, double> revenueByType;
  final double totalRevenue;
  final double previousQuarterRevenue;
  final double yearOverYearGrowth;
  final DateTime reportDate;

  RevenueReport({
    required this.teamId,
    required this.quarter,
    required this.year,
    required this.revenueByType,
    required this.totalRevenue,
    required this.previousQuarterRevenue,
    required this.yearOverYearGrowth,
    required this.reportDate,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    // Handle reportDate which can be either a Timestamp or String
    DateTime reportDate;
    if (json['reportDate'] is Timestamp) {
      reportDate = (json['reportDate'] as Timestamp).toDate();
    } else if (json['reportDate'] is String) {
      reportDate = DateTime.parse(json['reportDate']);
    } else {
      reportDate = DateTime.now();
    }

    return RevenueReport(
      teamId: json['teamId'] ?? '',
      quarter: Quarter.values.firstWhere(
        (e) => e.toString() == 'Quarter.${json['quarter']}',
        orElse: () => Quarter.q1,
      ),
      year: json['year'] ?? DateTime.now().year,
      revenueByType: Map<RevenueType, double>.from(
        (json['revenueByType'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            RevenueType.values.firstWhere(
              (e) => e.toString() == 'RevenueType.$key',
              orElse: () => RevenueType.other,
            ),
            (value ?? 0.0).toDouble(),
          ),
        ),
      ),
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      previousQuarterRevenue: (json['previousQuarterRevenue'] ?? 0.0).toDouble(),
      yearOverYearGrowth: (json['yearOverYearGrowth'] ?? 0.0).toDouble(),
      reportDate: reportDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'quarter': quarter.toString().split('.').last,
      'year': year,
      'revenueByType': revenueByType.map(
        (key, value) => MapEntry(key.toString().split('.').last, value),
      ),
      'totalRevenue': totalRevenue,
      'previousQuarterRevenue': previousQuarterRevenue,
      'yearOverYearGrowth': yearOverYearGrowth,
      'reportDate': reportDate.toIso8601String(),
    };
  }

  String get quarterDisplayName {
    switch (quarter) {
      case Quarter.q1:
        return 'Q1';
      case Quarter.q2:
        return 'Q2';
      case Quarter.q3:
        return 'Q3';
      case Quarter.q4:
        return 'Q4';
    }
  }

  double get growthPercentage => 
      previousQuarterRevenue > 0 
          ? ((totalRevenue - previousQuarterRevenue) / previousQuarterRevenue) * 100 
          : 0.0;
}

class PerformanceMetrics {
  final String teamId;
  final int season;
  final int wins;
  final int losses;
  final double winPercentage;
  final double merchandiseRevenue;
  final double totalRevenue;
  final double payroll;
  final double profitMargin;

  PerformanceMetrics({
    required this.teamId,
    required this.season,
    required this.wins,
    required this.losses,
    required this.winPercentage,
    required this.merchandiseRevenue,
    required this.totalRevenue,
    required this.payroll,
    required this.profitMargin,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      teamId: json['teamId'] ?? '',
      season: json['season'] ?? DateTime.now().year,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      winPercentage: (json['winPercentage'] ?? 0.0).toDouble(),
      merchandiseRevenue: (json['merchandiseRevenue'] ?? 0.0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      payroll: (json['payroll'] ?? 0.0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'season': season,
      'wins': wins,
      'losses': losses,
      'winPercentage': winPercentage,
      'merchandiseRevenue': merchandiseRevenue,
      'totalRevenue': totalRevenue,
      'payroll': payroll,
      'profitMargin': profitMargin,
    };
  }

  int get totalGames => wins + losses;
  double get roi => totalRevenue > 0 ? ((totalRevenue - payroll) / payroll) * 100 : 0.0;
} 