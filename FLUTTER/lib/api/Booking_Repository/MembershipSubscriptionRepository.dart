import 'dart:convert';

import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/booking/data/MembershipSubscription%20.dart';

class MembershipSubscriptionRepository {
  final ApiGateWayService _apiGateWayService;

  MembershipSubscriptionRepository(this._apiGateWayService);

  Future<MembershipSubscription> fetchMembershipSubscriptions(int userId) async {
    try{
       final response = await _apiGateWayService.getData('/paypal/getMembershipByUserId/$userId');
       print("Response data: ${response.data}");
       if (response.statusCode == 200) {
         final data = response.data['body'];
         print("Membership  Data :  $data");
         return MembershipSubscription.fromJson(data);
       } else {
         throw Exception('Failed to fetch MembershipSubscription. Status code: ${response.statusCode}');
       }
    }
    catch(e) {
      throw Exception('Failed to load subscriptions');
    }
  }
}