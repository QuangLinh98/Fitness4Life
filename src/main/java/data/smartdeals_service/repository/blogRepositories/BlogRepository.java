package data.smartdeals_service.repository.blogRepositories;


import data.smartdeals_service.models.blog.Blog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface BlogRepository extends JpaRepository<Blog, Long> {
}

