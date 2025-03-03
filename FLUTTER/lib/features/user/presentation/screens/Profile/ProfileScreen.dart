import 'package:fitness4life/features/user/presentation/screens/Profile/UpdateProfileScreen.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:fitness4life/features/user/data/models/UserResponseDTO.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      profileService.getUserById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context);
    final userProfile = profileService.userProfile;

    final userId = Provider.of<UserInfoProvider>(context).userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00020),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: userProfile?.profileDTO.avatar != null && userProfile!.profileDTO.avatar.isNotEmpty
                  ? NetworkImage(userProfile.profileDTO.avatar)
                  : null,
              child: userProfile == null || userProfile.profileDTO.avatar.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),


            const SizedBox(height: 20),
            userProfile != null
                ? Column(
              children: [
                _buildInfoRow("Name", userProfile.fullName),
                _buildInfoRow("Email", userProfile.email),
                _buildInfoRow("Phone", userProfile.phone),
                _buildInfoRow("Age", userProfile.profileDTO.age.toString()),
                _buildInfoRow("Gender", userProfile.gender.name),
                _buildInfoRow("Height", "${userProfile.profileDTO.heightValue} cm"),
                _buildInfoRow("Marital Status", userProfile.profileDTO.maritalStatus.toString().split('.').last),
                _buildInfoRow("Address", userProfile.profileDTO.address),
              ],
            )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 30),
            // ✅ Nút Update Profile luôn hiển thị
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfileScreen(userId: userId!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020), // Màu đỏ đậm
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Update Profile", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}