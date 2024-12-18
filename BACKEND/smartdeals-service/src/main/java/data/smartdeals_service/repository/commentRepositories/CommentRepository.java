package data.smartdeals_service.repository.commentRepositories;

import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CommentRepository extends JpaRepository<Comment, Long> {

    // Tìm danh sách các bình luận dựa trên blog ID
    @Query("SELECT c FROM Comment c WHERE c.blog.id = :blogId")
    List<Comment> findCommentsByBlogId(@Param("blogId") Long blogId);

    // Tìm danh sách các bình luận dựa trên question ID
    @Query("SELECT c FROM Comment c WHERE c.question.id = :questionId")
    List<Comment> findCommentsByQuestionId(@Param("questionId") Long questionId);
    Optional<Comment> findById(Long id);

    // Lấy tất cả bình luận liên quan đến một bài blog
//    List<Comment> findByBlog(Blog blog);
    Page<Comment> findByBlog(Blog blog, Pageable pageable);


    // Lấy tất cả bình luận liên quan đến một câu hỏi
    List<Comment> findByQuestion(Question question);

    // Lấy tất cả các bình luận gốc (không có bình luận cha) của một bài blog
    List<Comment> findByBlogAndParentCommentIsNull(Blog blog);

    // Lấy tất cả các bình luận gốc (không có bình luận cha) của một câu hỏi
    List<Comment> findByQuestionAndParentCommentIsNull(Question question);

    // Lấy tất cả các bình luận con của một bình luận cha
    List<Comment> findByParentComment(Comment parentComment);

    // Tìm tất cả các bình luận theo trạng thái xuất bản (published)
    List<Comment> findByIsPublished(Boolean isPublished);

    // Đếm số lượng bình luận của một bài blog
    Long countByBlog(Blog blog);

    // Đếm số lượng bình luận của một câu hỏi
    Long countByQuestion(Question question);

    List<Comment> findByBlogId(Long blogId);
//
//    List<Comment> findByParentCommentId(Long parentCommentId);
//
//    List<Comment> findByQuestionAndParentCommentIsNull(Question question);
//
//    List<Comment> findByParentComment(Comment parentComment);
}
