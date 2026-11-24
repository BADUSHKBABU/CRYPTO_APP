import '../../domain/entities/chart_point_entity.dart';

class ChartPointModel extends ChartPointEntity {
  const ChartPointModel({
    required super.timestamp,
    required super.price,
  });

  factory ChartPointModel.fromList(List<dynamic> list) {
    final timestampMillis = (list[0] as num).toInt();
    final price = (list[1] as num).toDouble();
    return ChartPointModel(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMillis),
      price: price,
    );
  }
}

