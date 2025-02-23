package kj001.user_service.controllers;

import kj001.user_service.dtos.UserDTO;
import kj001.user_service.dtos.UserResponseDTO;
import kj001.user_service.models.Profile;
import kj001.user_service.models.User;
import kj001.user_service.repository.UserRepository;
import kj001.user_service.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/users/")
@RequiredArgsConstructor
public class ManagerController {
    private final UserService userService;
    private final UserRepository userRepository;

    @GetMapping("manager/all")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> getAllUser(){
        List<UserResponseDTO> users =  userService.getAllUser();
        return ResponseEntity.ok(users);
    }

    @GetMapping("manager/users/{id}")
    //@PreAuthorize("hasAnyAuthority('ADMIN','USER')")
    public ResponseEntity<?> getUserById(@PathVariable long id){
        UserDTO userDTO = userService.getUserById(id);
        return ResponseEntity.ok(userDTO);
    }

    @GetMapping("manager/users/profile/{id}")
    @PreAuthorize("hasAnyAuthority('ADMIN','USER')")
    public ResponseEntity<?> getUserByIdToShowProfile(@PathVariable long id){
        UserResponseDTO user = userService.getUserByIdToShowProfile(id);
        return ResponseEntity.ok(user);
    }
}
