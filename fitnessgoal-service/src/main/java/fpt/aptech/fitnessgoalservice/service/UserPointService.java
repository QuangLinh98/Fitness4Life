package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserPoinDTO;
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
//    public int getPoints(long userId) {
//        return  pointRepository.findByUserId(userId)
//                .map(UserPoint::getTotalPoints)
//                .orElse(0);
//    }

    public UserPoinDTO getUserPoint(long userId) {
        UserPoint findUserPoint = pointRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("UserNotFound" ));
        UserPoinDTO userPoinDTO = new UserPoinDTO();
        if (findUserPoint!=null) {
            userPoinDTO.setUserId(userId);
            userPoinDTO.setTotalPoints(findUserPoint.getTotalPoints());
        }
        return userPoinDTO;
    }
    public UserPoinDTO approvePoint(long userId, int point) {
        UserPoint findUserPoint = pointRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("UserNotFound"));
        if (findUserPoint!=null) {
            int totalPoints = findUserPoint.getTotalPoints();
            switch (point) {
                case 500:
                case 1000:
                case 1500:
                case 2000:
                case 2500:
                case 3000:
                case 3500:
                case 4000:
                case 4500:
                case 5000:
                case 5500:
                case 6000:
                case 6500:
                case 7000:
                case 7500:
                case 8000:
                case 8500:
                case 9000:
                case 9500:
                case 10000:
                    if (totalPoints >= point) {
                        totalPoints -= point;
                        findUserPoint.setTotalPoints(totalPoints);
                        pointRepository.save(findUserPoint);
                    } else {
                        throw new RuntimeException("NotEnoughPointsToDeduct");
                    }
                    break;
                default:
                    throw new RuntimeException("InvalidPointId");
            }
        }
        UserPoinDTO userPoinDTO = new UserPoinDTO();
        userPoinDTO.setUserId(userId);
        userPoinDTO.setTotalPoints(findUserPoint.getTotalPoints());
        return userPoinDTO;
    }
}
