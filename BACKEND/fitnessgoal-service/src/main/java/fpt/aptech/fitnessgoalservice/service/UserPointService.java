package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.UserPoint;
import fpt.aptech.fitnessgoalservice.repository.UserPointRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserPointService {
    private final UserPointRepository pointRepository;
    private final UserEurekaClient userEurekaClient;

    //Handle method Increase Points ...

    public UserPoint addPoint(long userId, int point) {
        UserDTO existingUser = userEurekaClient.getUserById(userId);
        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }
        UserPoint userPoint = pointRepository.findByUserId(userId).orElse(new UserPoint(userId,0));

        //Cập nhật tổng điểm
        userPoint.setTotalPoints(userPoint.getTotalPoints() + point);
        pointRepository.save(userPoint);
        return userPoint;
    }

    //Handle get Point now
    public int getPoints(long userId) {
        return  pointRepository.findByUserId(userId)
                .map(UserPoint::getTotalPoints)
                .orElse(0);
    }
}
