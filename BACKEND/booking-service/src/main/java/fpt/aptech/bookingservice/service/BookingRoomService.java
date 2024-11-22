package fpt.aptech.bookingservice.service;

import fpt.aptech.bookingservice.dtos.BooKingRoomDTO;
import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.repository.BookingRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingRoomService {
    private final BookingRoomRepository bookingRoomRepository;

    //Handle get all data
    public List<BookingRoom>getAllBook() {
        return bookingRoomRepository.findAll();
    }

    //Handle get one BookRoom
    public BookingRoom getBookRoomById(int id) {
        return bookingRoomRepository.findById(id).get();
    }

    //Handle booking room
//    public BookingRoom saveBookRoom(BooKingRoomDTO booKRoomDTO) {
//
//    }
}
