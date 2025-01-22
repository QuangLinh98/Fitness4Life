import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/api/User_Repository/PasswordRepository.dart';
import 'package:fitness4life/api/User_Repository/RegisterRepository.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/Home/service/TrainerService.dart';
import 'package:fitness4life/features/booking/service/BookingRoomService.dart';
import 'package:fitness4life/features/booking/service/QrService.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:fitness4life/features/user/service/PasswordService.dart';
import 'package:fitness4life/features/user/service/RegisterService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../api/Dashboard_Repository/TrainerRepository.dart';
import 'locator_setup.dart';

//Quản lý các phụ thuộc của ứng dụng
List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => TrainerService(locator<TrainerRepository>())),
  ChangeNotifierProvider(create: (_) => RoomService(locator<RoomRepository>())),
  ChangeNotifierProvider(create: (_) => GoalService(locator<GoalRepository>())),
  ChangeNotifierProvider(create: (_) => BookingRoomService(locator<BookingRoomRepository>())),
  ChangeNotifierProvider(create: (_) => QrService(locator<QrRepository>(), locator<BookingRoomRepository>())),
  ChangeNotifierProvider(create: (_) => LoginService(locator<LoginRepository>())),
  ChangeNotifierProvider(create: (_) => RegisterService(locator<RegisterRepository>())),
  ChangeNotifierProvider(create: (_) => UserInfoProvider()),
  ChangeNotifierProvider(create: (_) => PasswordService(locator<PasswordRepository>())),

];