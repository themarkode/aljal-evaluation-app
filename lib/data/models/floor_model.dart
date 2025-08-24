class FloorModel {
  final String floorName; // اسم / رقم الدور
  final String floorDetails; // تفاصيل الدور

  FloorModel({required this.floorName, required this.floorDetails});

  // Convert JSON to FloorModel
  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      floorName: json['floorName'] ?? '',
      floorDetails: json['floorDetails'] ?? '',
    );
  }

  // Convert FloorModel to JSON
  Map<String, dynamic> toJson() {
    return {'floorName': floorName, 'floorDetails': floorDetails};
  }
}
