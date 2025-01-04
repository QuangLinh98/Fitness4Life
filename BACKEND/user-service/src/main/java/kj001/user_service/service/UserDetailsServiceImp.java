package kj001.user_service.service;

import kj001.user_service.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

// Đánh dấu class này là một service của Spring
@Service
public class UserDetailsServiceImp implements UserDetailsService {

    // Khai báo UserRepository để tương tác với cơ sở dữ liệu
    private final UserRepository repository;

    // Constructor injection để inject UserRepository
    public UserDetailsServiceImp(UserRepository repository) {
        this.repository = repository;
    }

    // Override phương thức loadUserByUsername từ interface UserDetailsService
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // Tìm người dùng theo email từ cơ sở dữ liệu
        return repository.findByEmail(email)
                // Nếu không tìm thấy thì throw ra ngoại lệ UsernameNotFoundException
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }
}
