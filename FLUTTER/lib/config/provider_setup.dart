import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/Home/service/TrainerService.dart';
import 'package:fitness4life/features/booking/service/BookingRoomService.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
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
];