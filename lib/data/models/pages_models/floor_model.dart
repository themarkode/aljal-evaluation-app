// Page name in Figma: 1.3 New Form

class FloorModel {
  final String? floorName; // اسم / رقم الدور
  final String? floorDetails; // تفاصيل الدور

  FloorModel({
    this.floorName,
    this.floorDetails,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      floorName: json['floorName'],
      floorDetails: json['floorDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floorName': floorName,
      'floorDetails': floorDetails,
    };
  }
}