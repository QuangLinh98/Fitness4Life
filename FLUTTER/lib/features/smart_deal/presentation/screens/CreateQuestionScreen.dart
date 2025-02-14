import 'dart:typed_data';
import 'package:fitness4life/features/smart_deal/service/QuestionService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../user/service/UserInfoProvider.dart';
import '../../data/models/forum/CreateQuestionDTO.dart';

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
    "MALE_FITNESS_PROGRAM": "Giáo Án Fitness Nam",
    "FEMALE_FITNESS_PROGRAM": "Giáo Án Fitness Nữ",
    "GENERAL_FITNESS_PROGRAM": "Giáo án Thể Hình",
    "FITNESS_QA": "Hỏi Đáp Thể Hình",
    "POSTURE_CORRECTION": "Sửa Tư Thế Kỹ Thuật Tập Luyện",
    "NUTRITION_EXPERIENCE": "Kinh Nghiệm Dinh Dưỡng",
    "SUPPLEMENT_REVIEW": "Review Thực Phẩm Bổ Sung",
    "WEIGHT_LOSS_QA": "Hỏi Đáp Giảm Cân - Giảm Mỡ",
    "MUSCLE_GAIN_QA": "Hỏi Đáp Tăng Cơ - Tăng Cân",
    "TRANSFORMATION_JOURNAL": "Nhật Ký Thay Đổi",
    "FITNESS_CHATS": "Tán Gẫu Liên Quan Fitness",
    "TRAINER_DISCUSSION": "HLV Thể Hình - Trao Đổi Công Việc",
    "NATIONAL_GYM_CLUBS": "CLB Phòng Gym Toàn Quốc",
    "FIND_WORKOUT_BUDDY": "Tìm Bạn Tập Cùng - Team Workout",
    "SUPPLEMENT_MARKET": "Mua Bán Thực Phẩm Bổ Sung",
    "EQUIPMENT_ACCESSORIES": "Dụng Cụ - Phụ Kiện Tập Luyện",
    "GYM_TRANSFER": "Sang Nhượng Phòng Tập",
    "MMA_DISCUSSION": "Võ Thuật Tổng Hợp MMA",
    "CROSSFIT_DISCUSSION": "Cross Fit",
    "POWERLIFTING_DISCUSSION": "Powerlifting",
  };

  String? _selectedCategoryKey;
  final List<Uint8List> _selectedImages = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImages.add(bytes);
      });
    }
  }

  Future<void> _createQuestion() async {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);

    String? userName = userInfo.userName;
    int? userId = userInfo.userId;

    // print("Có user với id không ta: ${userName} ${userId}");

    if (_formKey.currentState!.validate()) {
      final newQuestion = CreateQuestionDTO(
        authorId: userId!,
        author: userName!,
        title: _titleController.text,
        content: _contentController.text,
        tag: _tagController.text,
        status: "PENDING",
        category: [_selectedCategoryKey ?? ""],
        rolePost: "PUBLICED",
        imageQuestionUrl: _selectedImages,
      );


      final questionService = Provider.of<QuestionService>(context, listen: false);
      bool success = await questionService.CreateQuestion(newQuestion);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your question has been successfully created!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred, please try again!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Chiều cao AppBar
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB00020), // Đổi màu nền AppBar
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15), // Bo góc phía dưới
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Create new Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // Để căn giữa tiêu đề
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Title"),
                  validator: (value) => value!.isEmpty ? "Write a title pleass " : null,
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: "Content"),
                  maxLines: 4,
                  validator: (value) => value!.isEmpty ? "Write a content pleass" : null,
                ),
                TextFormField(
                  controller: _tagController,
                  decoration: InputDecoration(labelText: "Tag"),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryKey,
                  onChanged: (value) => setState(() => _selectedCategoryKey = value),
                  items: _categories.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: "Category"),
                  validator: (value) => value == null ? "Please select a category." : null,
                ),
                SizedBox(height: 10),
                Text("Attached images:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _selectedImages
                      .map((img) => Image.memory(img, width: 60, height: 60, fit: BoxFit.cover))
                      .toList(),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_a_photo),
                  label: Text("add images"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createQuestion,
                  child: Text("Create"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}