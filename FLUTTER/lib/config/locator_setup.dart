// File chứa hàm `setupLocator()` và cấu hình DI
import 'package:dio/dio.dart';
import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Booking_Repository/MembershipSubscriptionRepository.dart';
import 'package:fitness4life/api/Booking_Repository/PaypalRepository.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/api/Booking_Repository/WorkoutPackageRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/BranchRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/TrainerRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/api/Goal_Repository/ProgressRepository.dart';
import 'package:fitness4life/api/Notification_Repository/NotifyRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/BlogRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/CommentRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/PromotionRepository.dart';
import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/api/User_Repository/PasswordRepository.dart';
import 'package:fitness4life/api/User_Repository/ProfileRepository.dart';
import 'package:fitness4life/api/User_Repository/RegisterRepository.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:get_it/get_it.dart';

import '../api/SmartDeal_Repository/QuestionRepository.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  //Đăng ký đối tượng Dio (Http Client)
  locator.registerLazySingleton(() => Dio(BaseOptions (
    baseUrl: "http://172.16.12.48:9001/api", // API Gateway URL
    connectTimeout: const Duration(milliseconds: 10000), // Thời gian timeout kết nối
    receiveTimeout: const Duration(milliseconds: 10000), // Thời gian timeout nhận dữ liệu
  )));

  // Đăng ký ApiGateWayService (service để gọi API qua API Gateway)
  locator.registerLazySingleton(() => ApiGateWayService(locator<Dio>()));

  // Đăng ký TrainerRepository
  locator.registerLazySingleton(() => TrainerRepository(locator<ApiGateWayService>()));

  // Đăng ký BranchRepository
  locator.registerLazySingleton(() => BranchRepository(locator<ApiGateWayService>()));

  // Đăng ký RoomRepository
  locator.registerLazySingleton(() => RoomRepository(locator<ApiGateWayService>()));

  // Đăng ký GoalRepository
  locator.registerLazySingleton(() => GoalRepository(locator<ApiGateWayService>()));

  // Đăng ký ProgressRepository
  locator.registerLazySingleton(() => ProgressRepository(locator<ApiGateWayService>()));

  // Đăng ký BookingRepository
  locator.registerLazySingleton(() => BookingRoomRepository(locator<ApiGateWayService>()));

  // Đăng ký BookingRepository
  locator.registerLazySingleton(() => QrRepository(locator<ApiGateWayService>()));

  // Đăng ký LoginRepository
  locator.registerLazySingleton(() => LoginRepository(locator<ApiGateWayService>()));

  // Đăng ký RegisterRepository
  locator.registerLazySingleton(() => RegisterRepository(locator<ApiGateWayService>()));

  // Đăng ký ProfileRepository
  locator.registerLazySingleton(() => ProfileRepository(locator<ApiGateWayService>()));

  // Đăng ký PasswordRepository
  locator.registerLazySingleton(() => PasswordRepository(locator<ApiGateWayService>()));

  // Đăng ký MemberShipRepository
  locator.registerLazySingleton(() => MembershipSubscriptionRepository(locator<ApiGateWayService>()));

  // Đăng ký WorkoutPackageRepository
  locator.registerLazySingleton(() => WorkoutPackageRepository(locator<ApiGateWayService>()));

  // Đăng ký PayPalRepository
  locator.registerLazySingleton(() => PaypalRepository(locator<ApiGateWayService>()));

  // Đăng ký NotifyRepository
  locator.registerLazySingleton(() => NotifyRepository(locator<ApiGateWayService>()));

  // Đăng ký BlogRepository
  locator.registerLazySingleton(() => BlogRepository(locator<ApiGateWayService>()));

  // Đăng ký BlogRepository
  locator.registerLazySingleton(() => PromotionRepository(locator<ApiGateWayService>()));


  // Đăng ký QuestionRepository
  locator.registerLazySingleton(() => QuestionRepository(locator<ApiGateWayService>()));
  locator.registerLazySingleton(() => CommentRepository(locator<ApiGateWayService>()));
}