// import 'dart:typed_data';
// import 'package:fitness4life/features/smart_deal/service/QuestionService.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../../user/service/UserInfoProvider.dart';
// import '../../data/models/forum/CreateQuestionDTO.dart';
//
// class CreateQuestionScreen extends StatefulWidget {
//   @override
//   _CreateQuestionScreenState createState() => _CreateQuestionScreenState();
// }
//
// class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();
//   final TextEditingController _tagController = TextEditingController();
//   final Map<String, String> _categories = {
//     "MALE_FITNESS_PROGRAM": "Giáo Án Fitness Nam",
//     "FEMALE_FITNESS_PROGRAM": "Giáo Án Fitness Nữ",
//     "GENERAL_FITNESS_PROGRAM": "Giáo án Thể Hình",
//     "FITNESS_QA": "Hỏi Đáp Thể Hình",
//     "POSTURE_CORRECTION": "Sửa Tư Thế Kỹ Thuật Tập Luyện",
//     "NUTRITION_EXPERIENCE": "Kinh Nghiệm Dinh Dưỡng",
//     "SUPPLEMENT_REVIEW": "Review Thực Phẩm Bổ Sung",
//     "WEIGHT_LOSS_QA": "Hỏi Đáp Giảm Cân - Giảm Mỡ",
//     "MUSCLE_GAIN_QA": "Hỏi Đáp Tăng Cơ - Tăng Cân",
//     "TRANSFORMATION_JOURNAL": "Nhật Ký Thay Đổi",
//     "FITNESS_CHATS": "Tán Gẫu Liên Quan Fitness",
//     "TRAINER_DISCUSSION": "HLV Thể Hình - Trao Đổi Công Việc",
//     "NATIONAL_GYM_CLUBS": "CLB Phòng Gym Toàn Quốc",
//     "FIND_WORKOUT_BUDDY": "Tìm Bạn Tập Cùng - Team Workout",
//     "SUPPLEMENT_MARKET": "Mua Bán Thực Phẩm Bổ Sung",
//     "EQUIPMENT_ACCESSORIES": "Dụng Cụ - Phụ Kiện Tập Luyện",
//     "GYM_TRANSFER": "Sang Nhượng Phòng Tập",
//     "MMA_DISCUSSION": "Võ Thuật Tổng Hợp MMA",
//     "CROSSFIT_DISCUSSION": "Cross Fit",
//     "POWERLIFTING_DISCUSSION": "Powerlifting",
//   };
//
//   String? _selectedCategoryKey;
//   Future<void> _createQuestion() async {
//     final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
//     if (_formKey.currentState!.validate()) {
//       final newQuestion = CreateQuestionDTO(
//         authorId: userInfo.userId!,
//         author: userInfo.userName!,
//         title: _titleController.text,
//         content: _contentController.text,
//         tag: _tagController.text,
//         status: "PENDING",
//         category: [_selectedCategoryKey ?? ""],
//         rolePost: "PUBLICED",
//       );
//
//
//       final questionService = Provider.of<QuestionService>(context, listen: false);
//       bool success = await questionService.CreateQuestion(newQuestion);
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Your question has been successfully created!")),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An error occurred, please try again!")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(60), // Chiều cao AppBar
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFFB00020), // Đổi màu nền AppBar
//             borderRadius: BorderRadius.vertical(
//               bottom: Radius.circular(15), // Bo góc phía dưới
//             ),
//           ),
//           child: SafeArea(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: Text(
//                       "Create new Post",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 48), // Để căn giữa tiêu đề
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(labelText: "Title"),
//                   validator: (value) => value!.isEmpty ? "Write a title pleass " : null,
//                 ),
//                 TextFormField(
//                   controller: _contentController,
//                   decoration: InputDecoration(labelText: "Content"),
//                   maxLines: 4,
//                   validator: (value) => value!.isEmpty ? "Write a content pleass" : null,
//                 ),
//                 TextFormField(
//                   controller: _tagController,
//                   decoration: InputDecoration(labelText: "Tag"),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedCategoryKey,
//                   onChanged: (value) => setState(() => _selectedCategoryKey = value),
//                   items: _categories.entries.map((entry) {
//                     return DropdownMenuItem(
//                       value: entry.key,
//                       child: Text(entry.value),
//                     );
//                   }).toList(),
//                   decoration: InputDecoration(labelText: "Category"),
//                   validator: (value) => value == null ? "Please select a category." : null,
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _createQuestion,
//                   child: Text("Create"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../user/service/UserInfoProvider.dart';
import '../../data/models/forum/CreateQuestionDTO.dart';
import '../../service/QuestionService.dart';

class CreateQuestionScreen extends StatefulWidget {
  @override
  _CreateQuestionScreenState createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final Map<String, String> _categories = {
    "FITNESS_QA": "Fitness Q&A",
    "POSTURE_CORRECTION": "Exercise Form & Technique Correction",
    "NUTRITION_EXPERIENCE": "Nutrition Experience",
    "SUPPLEMENT_REVIEW": "Supplement Reviews",
    "WEIGHT_LOSS_QA": "Weight Loss & Fat Loss Q&A",
    "MUSCLE_GAIN_QA": "Muscle Gain & Weight Gain Q&A",
    "TRANSFORMATION_JOURNAL": "Transformation Journal",
    "FITNESS_CHATS": "Fitness Related Chats",
    "TRAINER_DISCUSSION": "Fitness Trainers - Job Exchange",
    "NATIONAL_GYM_CLUBS": "National Gym Clubs",
    "FIND_WORKOUT_BUDDY": "Find Workout Partners - Team Workout",
    "SUPPLEMENT_MARKET": "Supplement Marketplace",
    "EQUIPMENT_ACCESSORIES": "Training Equipment & Accessories",
    "GYM_TRANSFER": "Gym Transfer & Sales",
    "MMA_DISCUSSION": "Mixed Martial Arts (MMA)",
    "CROSSFIT_DISCUSSION": "CrossFit",
    "POWERLIFTING_DISCUSSION": "Powerlifting",
  };

  String? _selectedCategoryKey;

  Future<void> _createQuestion() async {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final newQuestion = CreateQuestionDTO(
        authorId: userInfo.userId!,
        author: userInfo.userName!,
        title: _titleController.text,
        content: _contentController.text,
        tag: _tagController.text,
        status: "PENDING",
        category: [_selectedCategoryKey ?? ""],
        rolePost: "PUBLICED",
      );

      final questionService = Provider.of<QuestionService>(context, listen: false);
      bool success = await questionService.CreateQuestion(newQuestion);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Your question has been successfully created!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ An error occurred, please try again!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField("Title", _titleController),
                _buildInputField("Content", _contentController, maxLines: 4),
                _buildInputField("Tag", _tagController),
                _buildCategoryDropdown(),
                SizedBox(height: 20),
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🌟 **AppBar với ảnh bìa đẹp mắt**
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFB00020),
      elevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/fitness_banner.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                "Create a New Post",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// ✨ **Hộp nhập liệu với viền mềm mại & hiệu ứng**
  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  /// 🎯 **Dropdown chọn danh mục**
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryKey,
        onChanged: (value) => setState(() => _selectedCategoryKey = value),
        items: _categories.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: "Category",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null ? "Please select a category." : null,
      ),
    );
  }

  /// 🔥 **Nút "Create" Gradient hiện đại**
  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _createQuestion,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            "Create Post",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
