import 'package:fitness4life/features/user/service/RegisterService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/user/presentation/screens/Profile/UpdateProfileScreen.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
// Import FaceIDService
import '../Login_Register/FaceIDRegisterScreen.dart';

class ProfileNotificationBanner extends StatelessWidget {
  const ProfileNotificationBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userInfoProvider = Provider.of<UserInfoProvider>(context);
    final profileService = Provider.of<ProfileService>(context);

    // If user is not logged in, don't show the banner
    if (userInfoProvider.userId == null) {
      return const SizedBox.shrink();
    }

    // Check if profile needs updating or Face ID needs registration
    final userProfile = profileService.userProfile;
    bool profileNeedsUpdate = userProfile == null ||
        userProfile.profileDTO.heightValue == 0 ||
        userProfile.profileDTO.age == 0 ||
        userProfile.profileDTO.address.isEmpty;

    // Check if Face ID is registered using the FaceIDService
    // final faceIDService = Provider.of<RegisterService>(context);
    bool faceIdNeeded = userProfile == null ||userProfile.faceDataDTO.faceEncoding == null;
    // If no updates needed, don't show the banner
    // if (!profileNeedsUpdate && !faceIdNeeded) {
    //   return const SizedBox.shrink();
    // }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Light orange background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D)), // Orange border
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Navigate to appropriate screen based on what needs updating
            if (userInfoProvider.userId != null) {
              if (profileNeedsUpdate) {
                // If profile needs update, go to profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(userId: userInfoProvider.userId!),
                  ),
                );
              } else if (faceIdNeeded) {
                // If only Face ID needed, go to Face ID registration
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceIDRegisterScreen(
                      userId: userProfile.id,
                      email: userProfile.email ?? "",
                      password: "", // You might need to handle this differently
                    ),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB74D), // Orange circle
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileNeedsUpdate && faceIdNeeded
                            ? "Please complete your profile & register Face ID"
                            : profileNeedsUpdate
                            ? "Please complete your profile"
                            : "Please register Face ID",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Tap here to update",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFFB74D),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}