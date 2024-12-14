package kj001.user_service.controllers;

import kj001.user_service.dtos.UserAndProfileUpdateDTO;
import kj001.user_service.dtos.UserDTO;
import kj001.user_service.dtos.UserResponseDTO;
import kj001.user_service.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateOneUser(@PathVariable Long id, @ModelAttribute UserAndProfileUpdateDTO userAndProfileUpdateDTO) throws IOException {
        Optional<UserResponseDTO> updateUser = userService.updateUser(id,userAndProfileUpdateDTO);
        if(updateUser.isPresent()){
            return ResponseEntity.ok(updateUser);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found or password mismatch.");
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOneUser(@PathVariable long id)  {
        UserResponseDTO deleteUser = userService.deleteUser(id);
        if (deleteUser != null) {
            return ResponseEntity.ok("delete User successfully...");
        }else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found with id : "+id);
        }
    }

    @PutMapping("/{userId}/workout-package")
    public ResponseEntity<UserDTO> assignWorkoutPackage(
            @PathVariable("userId") Long userId,
            @RequestParam("packageId") Integer packageId) {
        try {
            userService.assignPackageToUser(userId, packageId);
            // Tạo đối tượng UserDTO để trả về
            UserDTO userDTO = userService.getUserById(userId);
            return ResponseEntity.ok(userDTO);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
