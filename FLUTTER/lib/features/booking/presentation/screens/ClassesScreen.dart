import 'package:fitness4life/core/widgets/CustomDialog.dart';
import 'package:fitness4life/features/Home/data/Branch.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:fitness4life/features/Home/service/BranchService.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/booking/data/BookingRoom.dart';
import 'package:fitness4life/features/booking/presentation/screens/BookingDetailScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/WorkoutPackageScreen.dart';
import 'package:fitness4life/features/booking/service/BookingRoomService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassScreen extends StatefulWidget {
  int? roomId;

   ClassScreen({super.key,  this.roomId });

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  bool isBooked = false; // Biến trạng thái: true => hiển thị booked classes
  int? selectedBranchId;
  int? packageId;

  final List<String> images = [
    'images/cycling.jpg',
    'images/dance.jpg',
    'images/kickfit.jpg',
    'images/th.jpg',
    'images/yoga.jpg',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Gọi các service để lấy dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
      // Gọi fetchRooms
      final roomService = Provider.of<RoomService>(context, listen: false);
      roomService.fetchRooms();
      //roomService.fetchRoomsByPackage(packageId!);

      // Gọi fetchRooms
      final branchService = Provider.of<BranchService>(context, listen: false);
      branchService.fetchBranchs();

      //Gọi bookingRoom
      final bookingRoomService = Provider.of<BookingRoomService>(context, listen: false);
      if (userInfo.userId != null) {
        bookingRoomService.bookingRoom(widget.roomId!, userInfo.userId!);
      }

      //Gọi booked room by userId
      final bookedRoomService = Provider.of<BookingRoomService>(context, listen: false);
      if (userInfo.userId != null) {
        bookingRoomService.fetchBookedRooms(userInfo.userId!);
      }

      //Gọi cancel booking room
      final cancelBooking = Provider.of<BookingRoomService>(context, listen: false);
      cancelBooking.cancelBooking(widget.roomId!);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(8),
        child: AppBar(
          backgroundColor:  const Color(0xFFB00020),
          //title: Text('Fitness Gym', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      ),

      body: Container(
        child:  Column(
          children: [
            _buildFilterForm(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: const Color(0xFFB00020),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child:TextButton(
                        onPressed: () {
                          setState(() {
                            isBooked = false;  //Hiển thị tất cả room
                          });
                        },
                        child: Text('All classes', style: TextStyle(color: !isBooked ? Colors.white : Colors.red, fontSize: 16)),
                        style: TextButton.styleFrom(
                          backgroundColor: !isBooked ? Colors.red : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                  ),
                  Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isBooked = true ; //Hiển thị những lớp được book
                          });
                        },
                        child: Text('Booked classes', style: TextStyle(color: isBooked ? Colors.white : Colors.red, fontSize: 16)),
                        style: TextButton.styleFrom(
                          backgroundColor: isBooked ? Colors.red : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              //color: Color(0xFF9C9AFF),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(10, (index) {
                    // Lấy ngày hiện tại và cộng thêm index để có danh sách ngày liên tiếp
                    DateTime date = DateTime.now().add(Duration(days: index));

                    // Định dạng thứ (EEE) và ngày (dd)
                    String dayOfWeek = DateFormat('EEE').format(date); // Tue, Wed, Thu...
                    String dayOfMonth = DateFormat('d').format(date); // 25, 26, 27...

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: index == 0 ? Color(0xFFB8213D) : Colors.grey.shade500,
                              border: Border.all(
                                color: Colors.grey.shade700,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Column(
                              children: [
                                Text(
                                  dayOfWeek,
                                  style: TextStyle(
                                    color: index == 0 ? Colors.white : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  dayOfMonth,
                                  style: TextStyle(
                                    color: index == 0 ? Colors.white : Colors.grey.shade300,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            Expanded(
              child: isBooked ? _buildBookedClasses() : _buildAllClasses(),
            ),
          ],
        ),
      )

    );
  }

  // Xây dựng danh sách tất cả rooms
  Widget _buildAllClasses() {
    return Consumer<RoomService>(
      builder: (context, roomService, child) {
        final rooms = roomService.rooms;

        if (rooms.isEmpty) {
          return const Center(
            child: Text(
              "No classes available",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return buildUpcomingClassCard(room,index);
          },
        );
      },
    );
  }

  // Xây dựng danh sách các booked rooms
  Widget _buildBookedClasses() {
    return Consumer<BookingRoomService>(
      builder: (context, bookingRoomService, child) {
        final bookings = bookingRoomService.bookedRooms;

        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              "No booked classes available",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(booking);
          },
        );
      },
    );
  }

  // Card hiển thị thông tin những room đã được booking
  Widget _buildBookingCard(BookingRoom booking) {
    String formatDateTime(DateTime? dateTime) {
      if (dateTime != null) {
        return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
      }
      return 'N/A';
    }
    // Không hiển thị nếu trạng thái là "cancel"
    if (booking.status?.toLowerCase() == 'canceled') {
      return SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Colors.redAccent, // Màu viền
            width: 0.8,
          ),
      ),
      //color: const Color(0xFF392F7D),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.roomName!,
              style: const TextStyle(
                color: Color(0xFFB00020),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Booked by: ${booking.userName}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Booking Date: ${formatDateTime(booking.bookingDate)}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Status: ${booking.status}",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Đưa các nút về góc phải
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Xử lý sự kiện hủy booking
                      final bookingRoomService = Provider.of<BookingRoomService>(context, listen: false);
                      try {
                        await bookingRoomService.cancelBooking(booking.id ?? 0);

                        // Hiển thị dialog thông báo thành công
                        CustomDialog.show(
                          context,
                          title: "Success",
                          content: "Booking cancelled successfully!",
                          buttonText: "OK",
                          onButtonPressed: () {
                            // Xử lý sau khi đóng dialog, ví dụ load lại danh sách
                            setState(() {
                              Provider.of<BookingRoomService>(context, listen: false).fetchBookedRooms(booking.userId ?? 0);
                            });
                          },
                        );
                      } catch (e) {
                        // Hiển thị dialog thông báo thất bại
                        CustomDialog.show(
                          context,
                          title: "Error",
                          content: "Failed to cancel booking. Please try again.",
                          buttonText: "OK",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8), // Khoảng cách giữa hai nút
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển hướng đến trang chi tiết
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(bookingId: booking.id ?? 0),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Detail",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //Card hiển thị tất cả room
  Widget buildUpcomingClassCard(Room room, int index) {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    final userId = userInfo.userId;

    // Format thời gian
    String formatTime(List<int>? timeList) {
      if (timeList != null && timeList.length >= 2) {
        final hour = timeList[0];
        final minute = timeList[1];
        final now = DateTime.now();
        final time = DateTime(now.year, now.month, now.day, hour, minute);
        return DateFormat('hh:mm a').format(time);
      }
      return 'N/A';
    }

    // Kiểm tra nếu endTime đã qua thời gian thực tế
    DateTime now = DateTime.now();
    bool isRoomExpired = false;

    if (room.endtimeList != null && room.endtimeList!.length >= 2) {
      DateTime endTime = DateTime(
        now.year,
        now.month,
        now.day,
        room.endtimeList![0], // Giờ
        room.endtimeList![1], // Phút
      );

      isRoomExpired = now.isAfter(endTime); // 🔥 Kiểm tra nếu endTime đã qua
    }

    // Sử dụng chỉ số index để ánh xạ hình ảnh
    final image = images[index % images.length];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Colors.redAccent, // Màu viền
            width: 0.8, // Độ dày viền
        ),
      ),
      elevation: 10,  //Hiệu ứng đổ bóng card

      child: Row(
        children: [
          // HÌnh ảnh random
          Container(
            width: 90,
            height: 100,
            decoration:  BoxDecoration(
              //color: Colors.purple,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
            margin: const EdgeInsets.only(left: 12),
          ),
          const SizedBox(width: 12),
          // Thông tin lớp học
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên lớp học
                  Text(
                    room.roomname ?? "Unknown Room",
                    style: const TextStyle(
                      color: Color(0xFFB00020),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (room.trainer != null) ...[
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trainer: ${room.trainer!.fullName}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 4),
                  // Thời gian lớp học
                  Text(
                    "${formatTime(room.starttimeList)} - ${formatTime(room.endtimeList)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),


                  // Nút "Book"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Số chỗ trống
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color:  Color(0xFFB00020),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${room.availableseats ?? 0} / ${room.capacity}",
                            style: const TextStyle(
                              color: Color(0xFFB00020),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Nút "Book" hoặc "Full"
                      ElevatedButton(
                        onPressed: (isRoomExpired || (room.availableseats ?? 0) == (room.capacity ?? 0))
                            ? null // Vô hiệu hóa nút nếu đầy
                            : () async {
                          final userInfo = Provider.of<UserInfoProvider>(context , listen: false);

                          if(userInfo.workoutPackageId == 0 || userInfo.workoutPackageId == null) {
                            ///user chưa mua membership, chuyển đến workoutPackageScreen
                            CustomDialog.show(
                              context,
                              title: "Membership Required",
                              content: "You haven't signed up for an exercise pack. Please register before booking a class.",
                              buttonText: "OK",
                              onButtonPressed: () {
                                /// Chuyển đến trang WorkoutPackageScreen sau khi đóng dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WorkoutPackageScreen()),
                                );
                              },
                            );
                          }else {
                            ///User đã có membership tiến hành booking
                            try {
                              // Xử lý sự kiện click Book button
                              final bookingRoomService = Provider.of<
                                  BookingRoomService>(context, listen: false);
                              bool success = await bookingRoomService
                                  .bookingRoom(
                                  room.id ?? 0, userId!);

                              if (success) {
                                //Nếu booking thành công , hiển thị dialog thông báo thành công
                                CustomDialog.show(
                                  context,
                                  title: "Success",
                                  content: "Room booked successfully!",
                                  buttonText: "OK",
                                  onButtonPressed: () {
                                    setState(() {
                                      room.availableseats =
                                          (room.availableseats ?? 0) +
                                              1; //Cập nhật số ghế
                                    });
                                  },
                                );
                              }
                            } catch (error) {
                              print("❌ Caught error: $error"); // Log lỗi
                              print("❌ Error type: ${error.runtimeType}");

                              // Kiểm tra nếu đang ở trong cây widget hợp lệ
                              if (context.mounted) {
                                CustomDialog.show(
                                  context,
                                  title: "Error",
                                  content: extractErrorMessage(error),
                                  buttonText: "OK",
                                );
                              } else {
                                print(
                                    "🚨 Context is no longer valid. Cannot show dialog.");
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (room.availableseats ?? 0) == (room.capacity ?? 0)
                              ? Colors.grey // Màu xám khi đầy
                              : const Color(0xFFB00020), // Màu tím khi còn chỗ
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          (room.availableseats ?? 0) == (room.capacity ?? 0) ? "Full" : "Book",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm lấy thông báo lỗi từ Exception hoặc JSON response
  String extractErrorMessage(dynamic error) {
    if (error is String) {
      return error; // Nếu lỗi là chuỗi, trả về trực tiếp
    } else if (error is Exception) {
      final message = error.toString();
      if (message.contains("Failed to book room:")) {
        // Tách lấy message từ "Failed to book room:"
        return message.split("Failed to book room:")[1].trim();
      } else if (message.contains("Exception:")) {
        // Tách bỏ từ "Exception:"
        return message.split("Exception:")[1].trim();
      }
      return message; // Trả về toàn bộ chuỗi nếu không tách được
    } else {
      return "An unexpected error occurred. Please try again."; // Thông báo mặc định
    }
  }

  //Hàm filter room theo banchID
  Widget _buildFilterForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFB00020),
      child: Consumer<BranchService>(
        builder: (context, branchService, child) {
          if (branchService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (branchService.branchs.isEmpty) {
            return const Text("No branches available", style: TextStyle(color: Colors.white));
          }
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: "Select Branch",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            value: selectedBranchId,
            items: branchService.branchs.map((Branch branch) {
              return DropdownMenuItem<int>(
                value: branch.id,
                child: Text(branch.branchName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBranchId = value;
              });
              if (value != null) {
                final roomService = Provider.of<RoomService>(context, listen: false);
                roomService.fetchRoomsByBranchId(value);
              }
            },
          );
        },
      ),
    );
  }
}


