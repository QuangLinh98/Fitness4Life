import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
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
      // Gọi fetchRooms
      final roomService = Provider.of<RoomService>(context, listen: false);
      roomService.fetchRooms();

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(8),
        child: AppBar(
          backgroundColor:  Colors.purple.shade300,
          //title: Text('Fitness Gym', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9C9AFF), // Màu tím nhạt ở trên
              Color(0xFFB478BD), // Màu hồng nhẹ ở dưới
            ],
          ),
        ),
        child:  Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: Color(0xFF9C9AFF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('All classes', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: TextButton.styleFrom(
                      //backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Booked classes', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Color(0xFF9C9AFF),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(10, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: index == 0 ? Colors.purple : Colors.grey,
                              border: Border.all(
                                color: Colors.grey.shade600,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Column(
                              children: [
                                Text(
                                  ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'][index],
                                  style: TextStyle(
                                    color: index == 0 ? Colors.white : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  (25 + index).toString(),
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
              child: Consumer<RoomService>(
                builder: (context, roomService, child) {
                  if (roomService.rooms.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Upcoming Classes Available",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: roomService.rooms.length,
                    itemBuilder: (context, index) {
                      final room = roomService.rooms[index];
                      return buildUpcomingClassCard(room,index);
                    },
                  );
                },
              ),
            ),

          ],
        ),
      )

    );
  }

  //Xử lý Upcoming Classes
  Widget buildUpcomingClassCard(Room room, int index) {
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

    // Sử dụng chỉ số index để ánh xạ hình ảnh
    final image = images[index % images.length];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF392F7D),
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Thời gian lớp học
                  Text(
                    "${formatTime(room.starttimeList)} - ${formatTime(room.endtimeList)}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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
                            color:  Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${room.availableseats ?? 0} / ${room.capacity}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Xử lý khi nhấn nút
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9747FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Book",
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
}


