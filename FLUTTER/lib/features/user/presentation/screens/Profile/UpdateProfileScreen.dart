import 'package:fitness4life/features/user/presentation/screens/Profile/ProfileScreen.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/CustomDialog.dart';

class UpdateProfileScreen extends StatefulWidget {
  final int userId;

  const UpdateProfileScreen({Key? key, required this.userId}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final userProfile = await profileService.getUserById(widget.userId);

    if (userProfile != null) {
      setState(() {
        fullNameController.text = userProfile.fullName;
        phoneController.text = userProfile.phone;
        hobbiesController.text = userProfile.profileDTO.hobbies;
        addressController.text = userProfile.profileDTO.address;
        ageController.text = userProfile.profileDTO.age.toString();
        heightController.text = userProfile.profileDTO.heightValue.toString();
        descriptionController.text = userProfile.profileDTO.description;
        gender = userProfile.gender.toString().split('.').last;
        maritalStatus = userProfile.profileDTO.maritalStatus.toString().split('.').last;
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profileService = Provider.of<ProfileService>(context, listen: false);
      final bool success = await profileService.updateUserProfile(
        userId: widget.userId,
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId))
            );
          },
        );
      } else {
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
        title: const Text("Update Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    const SizedBox(width: 10),
                    Expanded(child: buildDropdownField("Marital Status", ["SINGLE", "MARRIED"], (val) => maritalStatus = val)),
                  ],
                ),
                buildTextField("Hobbies", hobbiesController),
                buildTextField("Address", addressController),
                Row(
                  children: [
                    Expanded(child: buildTextField("Age", ageController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Height (cm)", heightController, keyboardType: TextInputType.number)),
                  ],
                ),
                buildTextField("Description", descriptionController, maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB00020),
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
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          errorStyle: const TextStyle(color: Colors.white),
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
          border: const OutlineInputBorder(),
          errorStyle: const TextStyle(color: Colors.white),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "$label is required" : null,

      ),
    );
  }
}
