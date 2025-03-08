import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';

import '../../../../config/constants.dart';
import '../../../../core/widgets/CustomDialog.dart';
import '../../../user/service/UserInfoProvider.dart';
import '../../service/BookingRoomService.dart';
import 'ClassesScreen.dart';

class ClassDetailScreen extends StatefulWidget {
  final int roomId;

  const ClassDetailScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    final roomService = Provider.of<RoomService>(context, listen: false);

    // Dừng polling khi vào màn hình này để tránh reload liên tục
    //roomService.stopPolling();


    //  Gọi API ngay khi mở màn hình để lấy dữ liệu mới nhất
    Future.microtask(() async {
      await roomService.getRoomById(widget.roomId); // Lấy dữ liệu phòng theo ID
    });
  }

  /// Kiểm tra nếu thời gian hiện tại đã qua startTime
  bool isRoomExpired(Room room) {
    DateTime now = DateTime.now();

    if (room.starttimeList != null && room.starttimeList!.length >= 2) {
      DateTime startTime = DateTime(
        now.year,
        now.month,
        now.day,
        room.starttimeList![0], // Giờ
        room.starttimeList![1], // Phút
      );
      return now.isAfter(startTime); // 🔥 Nếu thời gian hiện tại đã qua startTime, phòng hết hạn
    }
    return false;
  }

  @override
  void dispose() {
    final roomService = Provider.of<RoomService>(context, listen: false);

    // Bật lại polling khi rời khỏi màn hình
    //roomService.startPolling();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingRoomService = Provider.of<BookingRoomService>(context, listen: false);
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Tăng chiều cao AppBar
        child: AppBar(
          backgroundColor: const Color(0xFFB00020),
          title: const Text("Class Detail", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
      ),
      body: Consumer<RoomService>(
        builder: (context, roomService, child) {
          if (roomService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final Room? room = roomService.room;
          if (room == null) {
            return const Center(
              child: Text(
                "Room not found!",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          bool isRoomFull = (room.availableseats ?? 0) >= (room.capacity ?? 0);
          bool roomExpired = isRoomExpired(room);
          bool isInPackage = roomService.isRoomInPackage(room.id ?? 0);

          String originalUrl = room.trainer?.photo ?? '';
          String correctedUrl = getFullImageUrl(originalUrl);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh Background
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/yoga.jpg"), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên phòng
                      Text(
                        room.roomname ?? "Unknown Room",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Capacity: ${room.capacity} | Available Seats: ${room.availableseats}",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 15),

                      // Thời gian lớp học
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            "${room.starttimeList?.join(':')} - ${room.endtimeList?.join(':')}",
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Mô tả phòng
                      Text(
                        room.facilities ?? "No facilities available.",
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Thông tin huấn luyện viên
                      const Text(
                        "Instructor",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                           CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(correctedUrl), // Placeholder
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.trainer?.fullName ?? "No Instructor",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Experience: ${room.trainer?.experienceyear ?? 'N/A'} years",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Nút đặt phòng với trạng thái cập nhật
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (isRoomFull || roomExpired || !isInPackage)
                              ? null
                              : () async {
                            try {
                              bool success = await bookingRoomService.bookingRoom(
                                room.id ?? 0,
                                userInfo.userId!,
                              );

                              if (success) {
                                // Cập nhật lại dữ liệu phòng sau khi đặt thành công
                                await roomService.getRoomById(widget.roomId);

                                // Hiển thị thông báo đặt thành công
                                CustomDialog.show(
                                  context,
                                  title: "Success",
                                  content: "Room booked successfully!",
                                  buttonText: "OK",
                                  onButtonPressed: () {
                                    // Quay về màn hình chính và chọn tab "Booked Classes"
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  },
                                );
                              }
                            } catch (e) {
                              CustomDialog.show(
                                context,
                                title: "Error",
                                content: "Failed to book the room. Please try again.",
                                buttonText: "OK",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (!isInPackage || isRoomFull || roomExpired)
                                ? Colors.grey
                                : const Color(0xFFB00020),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            !isInPackage
                                ? "Not in Package"
                                : isRoomFull
                                ? "Full"
                                : roomExpired
                                ? "Expired"
                                : "Book",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
