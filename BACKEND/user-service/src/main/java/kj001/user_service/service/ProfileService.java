package kj001.user_service.service;

import kj001.user_service.models.Profile;
import kj001.user_service.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileService {
    private final ProfileRepository profileRepository;

    public Profile getProfileById(Long id) {
        return profileRepository.findById(id).orElseThrow(()->new RuntimeException("Profile not found"));
    }
}
