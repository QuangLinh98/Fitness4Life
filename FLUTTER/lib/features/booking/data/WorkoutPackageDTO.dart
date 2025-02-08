
enum PackageName {
  CLASSIC,
  CLASSIC_PLUS,
  PRESIDENT,
  ROYAL,
  SIGNATURE,
}

class WorkoutPackageDTO {
  final int id;
  final PackageName packageName;
  final double price;

  WorkoutPackageDTO({
    required this.id,
    required this.packageName,
    required this.price,
  });

  factory WorkoutPackageDTO.fromJson(Map<String, dynamic> json) {
    final packageData = json['data'] as Map<String, dynamic>? ?? json;

    return WorkoutPackageDTO(
      id: (packageData['id'] as num?)?.toInt() ?? 0,
      packageName: packageData['packageName'] != null
          ? PackageName.values.firstWhere(
            (e) => e.toString().split('.').last == packageData['packageName'],
        orElse: () => PackageName.CLASSIC,
      )
          : PackageName.CLASSIC,
      price: (packageData['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "packageName": packageName.toString().split('.').last,
      "price": price,
    };
  }
}
