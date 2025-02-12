// File chứa hàm `setupLocator()` và cấu hình DI
import 'package:dio/dio.dart';
import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/TrainerRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/PromotionRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/QuestionRepository.dart';
import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/api/User_Repository/PasswordRepository.dart';
import 'package:fitness4life/api/User_Repository/RegisterRepository.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:get_it/get_it.dart';

import '../api/SmartDeal_Repository/BlogRepository.dart';
import '../api/SmartDeal_Repository/CommentRepository.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  //Đăng ký đối tượng Dio (Http Client)
  locator.registerLazySingleton(() => Dio(BaseOptions (
    baseUrl: "http://192.168.1.3:9000/api", // API Gateway URL
    connectTimeout: const Duration(milliseconds: 10000), // Thời gian timeout kết nối
    receiveTimeout: const Duration(milliseconds: 10000), // Thời gian timeout nhận dữ liệu
  )));

  // Đăng ký ApiGateWayService (service để gọi API qua API Gateway)
  locator.registerLazySingleton(() => ApiGateWayService(locator<Dio>()));

  // Đăng ký TrainerRepository
  locator.registerLazySingleton(() => TrainerRepository(locator<ApiGateWayService>()));

  // Đăng ký RoomRepository
  locator.registerLazySingleton(() => RoomRepository(locator<ApiGateWayService>()));

  // Đăng ký RoomRepository
  locator.registerLazySingleton(() => GoalRepository(locator<ApiGateWayService>()));

  // Đăng ký BookingRepository
  locator.registerLazySingleton(() => BookingRoomRepository(locator<ApiGateWayService>()));

  // Đăng ký BookingRepository
  locator.registerLazySingleton(() => QrRepository(locator<ApiGateWayService>()));

  // Đăng ký LoginRepository
  locator.registerLazySingleton(() => LoginRepository(locator<ApiGateWayService>()));

  // Đăng ký RegisterRepository
  locator.registerLazySingleton(() => RegisterRepository(locator<ApiGateWayService>()));

  // Đăng ký PasswordRepository
  locator.registerLazySingleton(() => PasswordRepository(locator<ApiGateWayService>()));

  // Đăng ký QuestionRepository
  locator.registerLazySingleton(() => QuestionRepository(locator<ApiGateWayService>()));

  // Đăng ký CommentRepository
  locator.registerLazySingleton(() => CommentRepository(locator<ApiGateWayService>()));

  // Đăng ký PromotionRepository
  locator.registerLazySingleton(() => PromotionRepository(locator<ApiGateWayService>()));

  // Đăng ký BlogRepository
  locator.registerLazySingleton(() => BlogRepository(locator<ApiGateWayService>()));


}