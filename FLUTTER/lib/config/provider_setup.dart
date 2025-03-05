import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Booking_Repository/MembershipSubscriptionRepository.dart';
import 'package:fitness4life/api/Booking_Repository/PaypalRepository.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/api/Booking_Repository/WorkoutPackageRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/BranchRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/api/Goal_Repository/ProgressRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/BlogRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/CommentRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/PromotionRepository.dart';
import 'package:fitness4life/api/SmartDeal_Repository/QuestionRepository.dart';
import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/api/User_Repository/PasswordRepository.dart';
import 'package:fitness4life/api/User_Repository/ProfileRepository.dart';
import 'package:fitness4life/api/User_Repository/RegisterRepository.dart';
import 'package:fitness4life/features/Home/service/BranchService.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/Home/service/TrainerService.dart';
import 'package:fitness4life/features/booking/service/BookingRoomService.dart';
import 'package:fitness4life/features/booking/service/MembershipSubscriptionService.dart';
import 'package:fitness4life/features/booking/service/PaypalService.dart';
import 'package:fitness4life/features/booking/service/QrService.dart';
import 'package:fitness4life/features/booking/service/WorkoutPackageService.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/fitness_goal/service/ProgressService.dart';
import 'package:fitness4life/features/smart_deal/service/BlogService.dart';
import 'package:fitness4life/features/smart_deal/service/CommentService.dart';
import 'package:fitness4life/features/smart_deal/service/PromotionService.dart';
import 'package:fitness4life/features/smart_deal/service/QuestionService.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:fitness4life/features/user/service/PasswordService.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:fitness4life/features/user/service/RegisterService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../api/Dashboard_Repository/TrainerRepository.dart';
import '../api/Notification_Repository/NotifyRepository2.dart';
import '../features/notification/service/NotificationProvider.dart';
import '../features/notification/service/NotifyService2.dart';
import '../features/notification/service/WebSocketService.dart';
import 'locator_setup.dart';

//Quản lý các phụ thuộc của ứng dụng
List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => TrainerService(locator<TrainerRepository>())),
  ChangeNotifierProvider(create: (_) => BranchService(locator<BranchRepository>())),
  ChangeNotifierProvider(create: (_) => RoomService(locator<RoomRepository>())),
  ChangeNotifierProvider(create: (_) => GoalService(locator<GoalRepository>())),
  ChangeNotifierProvider(create: (_) => ProgressService(locator<ProgressRepository>())),
  ChangeNotifierProvider(create: (_) => BookingRoomService(locator<BookingRoomRepository>(),locator<RoomRepository>())),
  ChangeNotifierProvider(create: (_) => QrService(locator<QrRepository>(), locator<BookingRoomRepository>())),
  ChangeNotifierProvider(create: (_) => LoginService(locator<LoginRepository>())),
  ChangeNotifierProvider(create: (_) => RegisterService(locator<RegisterRepository>())),
  ChangeNotifierProvider(create: (_) => ProfileService(locator<ProfileRepository>())),
  ChangeNotifierProvider(create: (context) => UserInfoProvider(context.read<ProfileService>())),
  //ChangeNotifierProvider(create: (_) => UserInfoProvider(),
  ChangeNotifierProvider(create: (_) => PasswordService(locator<PasswordRepository>())),
  ChangeNotifierProvider(create: (_) => MembershipSubscriptionService(locator<MembershipSubscriptionRepository>())),
  ChangeNotifierProvider(create: (_) => WorkoutPackageService(locator<WorkoutPackageRepository>())),
  ChangeNotifierProvider(create: (_) => PaypalService(locator<PaypalRepository>())),
  ChangeNotifierProvider(create: (_) => QuestionService(locator<QuestionRepository>())),
  ChangeNotifierProvider(create: (_) => CommentService(locator<CommentRepository>())),
  // Notification services
  ChangeNotifierProvider(create: (_) => NotifyService2(locator<NotifyRepository2>())),
  ChangeNotifierProvider(create: (_) => NotificationProvider(
    locator<NotifyService2>(),
    locator<WebSocketService>(),
  )),

  ChangeNotifierProvider(create: (_) => BlogService(locator<BlogRepository>())),
  ChangeNotifierProvider(create: (_) => PromotionService(locator<PromotionRepository>())),

  // Thêm GoalSetupState sử dụng để lưu trữ giá trị tamk thời khi thiết lập goal
  ChangeNotifierProvider(create: (_) => GoalSetupState()),
];