class LoanModel {
  final String id;
  final String userId;
  final String transportId;
  final DateTime startTime;
  final DateTime? endTime;
  final String startStationId;
  final String? endStationId;
  final double cost;

  LoanModel({
    required this.id,
    required this.userId,
    required this.transportId,
    required this.startTime,
    this.endTime,
    required this.startStationId,
    this.endStationId,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'transportId': transportId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startStationId': startStationId,
      'endStationId': endStationId,
      'cost': cost,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      id: id,
      userId: map['userId'] ?? '',
      transportId: map['transportId'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      startStationId: map['startStationId'] ?? '',
      endStationId: map['endStationId'],
      cost: map['cost']?.toDouble() ?? 0.0,
    );
  }
}