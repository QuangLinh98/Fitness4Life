// File chứa hàm `setupLocator()` và cấu hình DI
import 'package:dio/dio.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/TrainerRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  //Đăng ký đối tượng Dio (Http Client)
  locator.registerLazySingleton(() => Dio(BaseOptions (
    baseUrl: "http://192.168.1.20:9000/api", // API Gateway URL
    connectTimeout: const Duration(milliseconds: 5000), // Thời gian timeout kết nối
    receiveTimeout: const Duration(milliseconds: 3000), // Thời gian timeout nhận dữ liệu
  )));

  // Đăng ký ApiGateWayService (service để gọi API qua API Gateway)
  locator.registerLazySingleton(() => ApiGateWayService(locator<Dio>()));

  // Đăng ký TrainerRepository
  locator.registerLazySingleton(() => TrainerRepository(locator<ApiGateWayService>()));

  // Đăng ký RoomRepository
  locator.registerLazySingleton(() => RoomRepository(locator<ApiGateWayService>()));

  // Đăng ký RoomRepository
  locator.registerLazySingleton(() => GoalRepository(locator<ApiGateWayService>()));
}