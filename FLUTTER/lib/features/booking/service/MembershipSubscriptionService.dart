import 'package:fitness4life/api/Booking_Repository/MembershipSubscriptionRepository.dart';
import 'package:fitness4life/features/booking/data/MembershipSubscription%20.dart';
import 'package:flutter/material.dart';

class MembershipSubscriptionService extends ChangeNotifier {
  final MembershipSubscriptionRepository _membershipSubscriptionRepository;
  MembershipSubscriptionService(this._membershipSubscriptionRepository);

  MembershipSubscription? _membershipSubscription;
  String? _errorMessage;

  MembershipSubscription? get membershipSubscription => _membershipSubscription;
  String? get errorMessage => _errorMessage;

  Future<void> getMembershipSubscription(int userId) async {
    print("🔄 Đang gọi API lấy Membership cho userId: $userId");
    try {
      _errorMessage = null; // Reset lỗi trước mỗi request
      final data = await _membershipSubscriptionRepository.fetchMembershipSubscriptions(userId);

      if (data != null) {
        _membershipSubscription = data; // 🔥 Lưu dữ liệu vào state
        print("✅ Đã nhận dữ liệu Membership: $_membershipSubscription");
        notifyListeners(); // 🔥 Cập nhật UI
      }
    } catch (e, stacktrace) {
      _errorMessage = "❌ Lỗi lấy Membership: $e";
      print("❌ Lỗi trong Service: $e");
      print("🔍 StackTrace: $stacktrace");

      notifyListeners(); // 🔥 Cập nhật UI để hiển thị lỗi
    }
  }
}

