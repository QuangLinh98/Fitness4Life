import 'package:fitness4life/features/user/presentation/screens/Profile/ProfileScreen.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/CustomDialog.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController hobbiesController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? gender;
  String? maritalStatus;

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profileService = Provider.of<ProfileService>(context, listen: false);
      final userId = Provider.of<UserInfoProvider>(context, listen: false).userId ?? 0;
      final bool success = await profileService.updateUserProfile(
        userId: userId,
        fullName: fullNameController.text,
        phone: phoneController.text,
        gender: gender!,
        maritalStatus: maritalStatus!,
        hobbies: hobbiesController.text,
        address: addressController.text,
        age: int.parse(ageController.text),
        heightValue: int.parse(heightController.text),
        description: descriptionController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        CustomDialog.show(
          context,
          title: "Success",
          content: "Update profile successfully!",
          buttonText: "OK",
          onButtonPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen())
            );
          },
        );
      } else {
        // Ở lại trang hiện tại và hiển thị thông báo lỗi
        CustomDialog.show(
          context,
          title: "Error",
          content: "Update profile failed!",
          buttonText: "OK",
          onButtonPressed: () {
            Navigator.of(context).pop();
          },
        );
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB00020),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00020),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildTextField("Full Name", fullNameController),
                buildTextField("Phone", phoneController, keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Expanded(child: buildDropdownField("Gender", ["MALE", "FEMALE", "OTHER"], (val) => gender = val)),
                    SizedBox(width: 10),
                    Expanded(child: buildDropdownField("Marital Status", ["SINGLE", "MARRIED"], (val) => maritalStatus = val)),
                  ],
                ),
                buildTextField("Hobbies", hobbiesController),
                buildTextField("Address", addressController),
                Row(
                  children: [
                    Expanded(child: buildTextField("Age", ageController, keyboardType: TextInputType.number)),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField("Height (cm)", heightController, keyboardType: TextInputType.number)),
                  ],
                ),
                buildTextField("Description", descriptionController, maxLines: 3),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB00020),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Update Profile", style: TextStyle(fontSize: 18, color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          errorStyle: TextStyle(color: Colors.white),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.black),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: Colors.black)))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "$label is required" : null,
      ),
    );
  }
}
