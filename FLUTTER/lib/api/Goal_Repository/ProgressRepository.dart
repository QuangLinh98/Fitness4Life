import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/Progress.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/ProgressDTO.dart';

class ProgressRepository {
  final ApiGateWayService _apiGateWayService;

  ProgressRepository(this._apiGateWayService);

  ///Lấy Progress theo goalID
  Future<List<Progress>> getProgressByGoalId(int goalId) async {
    try {
      final response = await _apiGateWayService.getData('/goal/progress/$goalId');

      if (response.data != null && response.data is List) {
        return (response.data as List).map((json) {
          return Progress.fromJson(json);
        }).toList();
      } else {
        throw Exception("Invalid data structure: Expected a List.");
      }
    } catch (e, stackTrace) {
      print("Error fetching progress: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error fetching progress: $e");
    }
  }

  ///Tạo Progress
  Future<ProgressDTO> createProgress(ProgressDTO progress) async {
    try {
      final response = await _apiGateWayService.postData(
        '/goal/progress/add',
        data: progress.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // ✅ Kiểm tra nếu `responseData` là `null`
        if (responseData == null || !responseData.containsKey('data')) {
          throw Exception('Invalid response format: Missing "data" key');
        }

        // ✅ Xử lý trường hợp `trackingDate` trả về dạng `[YYYY, MM, DD]`
        Map<String, dynamic> formattedData = Map<String, dynamic>.from(responseData['data']);

        if (formattedData.containsKey("trackingDate") && formattedData["trackingDate"] is List) {
          formattedData["trackingDate"] = _formatDateList(formattedData["trackingDate"]);
        }

        if (formattedData.containsKey("createdAt") && formattedData["createdAt"] is List) {
          formattedData["createdAt"] = _formatDateTimeList(formattedData["createdAt"]);
        }

        return ProgressDTO.fromJson(formattedData);
      } else {
        throw Exception('Failed to create progress. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("Error submitting progress: $e\n$stackTrace");
      rethrow; // Ném lỗi để Service xử lý
    }
  }

  /// **Chuyển đổi `[YYYY, MM, DD]` thành chuỗi `YYYY-MM-DD`**
  String _formatDateList(List<dynamic> dateList) {
    if (dateList.length >= 3) {
      return "${dateList[0]}-${dateList[1].toString().padLeft(2, '0')}-${dateList[2].toString().padLeft(2, '0')}";
    }
    return "";
  }

  /// **Chuyển đổi `[YYYY, MM, DD, HH, MM, SS, MS]` thành chuỗi `YYYY-MM-DD HH:MM:SS`**
  String _formatDateTimeList(List<dynamic> dateTimeList) {
    if (dateTimeList.length >= 6) {
      return "${dateTimeList[0]}-${dateTimeList[1].toString().padLeft(2, '0')}-${dateTimeList[2].toString().padLeft(2, '0')} "
          "${dateTimeList[3].toString().padLeft(2, '0')}:${dateTimeList[4].toString().padLeft(2, '0')}:${dateTimeList[5].toString().padLeft(2, '0')}";
    }
    return "";
  }

}