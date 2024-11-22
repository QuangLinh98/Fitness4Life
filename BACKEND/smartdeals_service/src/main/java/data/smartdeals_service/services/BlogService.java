package data.smartdeals_service.services;

import data.smartdeals_service.helpers.*;
import data.smartdeals_service.dto.*;
import data.smartdeals_service.models.*;
import data.smartdeals_service.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BlogService {
    private final BlogRepository blogRepository;
    private final BlogImageRepository blogImageRepository;
    private final CommentRepository commentRepository;

    private final FileUploadAvata fileUploadAvata;
    private String subFolder = "BlogImage";
    private String urlImage = GlobalConstant.rootUrl
            + GlobalConstant.uploadFolder + File.separator + subFolder;

    // show all blog
    public List<Blog> findAll() {
        return blogRepository.findAll();
    }

    //Get One Blog voi Id
    public Optional<Blog> findById(Long id) {
        return blogRepository.findById(id);
    }

    //Tao Blog
    public Blog CreateBlog(CreateBlogDTO createBlogDTO) throws IOException {
        Blog blog = new Blog();
        blog.setAuthorName(createBlogDTO.getAuthorName());
        blog.setTitle(createBlogDTO.getTitle());
        blog.setContent(createBlogDTO.getContent());
        blog.setCategory(createBlogDTO.getCategory());
        blog.setTags(createBlogDTO.getTags());
        blog.setCreatedAt(LocalDateTime.now());
        blog.setUpdatedAt(null);
        blog.setIsPublished(true);
        blog.setViewCount(0);
        blog.setLikesCount(0);
        Blog savedBlog = blogRepository.save(blog);
        List<BlogImage> blogImages = new ArrayList<>();
        for (MultipartFile image : createBlogDTO.getThumbnailUrl()) {
            String imageName = fileUploadAvata.storeImage(subFolder, image);
            String exactImageUrl = urlImage + File.separator + imageName;
            BlogImage blogImage = new BlogImage();
            blogImage.setImageUrl(exactImageUrl.replace("\\", "/"));
            blogImage.setBlog(savedBlog);
            blogImages.add(blogImage);
        }
        blog.setThumbnailUrl(blogImages);
        blogImageRepository.saveAll(blogImages);
        return savedBlog;
    }

    public Blog UpdateBlog(Long id, UpdateBlogDTO updateBlogDTO) throws IOException {
        Blog blogs = blogRepository.findById(id).orElse(null);
        if (blogs == null) {
            return null;
        }
        blogs.setTitle(updateBlogDTO.getTitle());
        blogs.setContent(updateBlogDTO.getContent());
        blogs.setUpdatedAt(LocalDateTime.now());
        blogs.setCategory(updateBlogDTO.getCategory());
        blogs.setTags(updateBlogDTO.getTags());

        if(updateBlogDTO.getDeleteImageUrl() != null && !updateBlogDTO.getDeleteImageUrl().isEmpty()) {

            List<BlogImage> imagesToDelete = blogs.getThumbnailUrl().stream()

                    .filter(image -> updateBlogDTO.getDeleteImageUrl()
                            .contains(image.getId()))
                    .collect(Collectors.toList());

            for (BlogImage image : imagesToDelete) {
                fileUploadAvata.deleteImage(image.getImageUrl().substring(GlobalConstant.rootUrl.length()));
                blogs.getThumbnailUrl().remove(image);
                blogImageRepository.delete(image);
            }
        }

        if (updateBlogDTO.getThumbnailUrl() != null) {
            List<MultipartFile> nonEmptyFiles = Arrays.stream(updateBlogDTO.getThumbnailUrl())
                    .filter(file -> file != null && !file.isEmpty())
                    .collect(Collectors.toList());
            if (!nonEmptyFiles.isEmpty()) {
                List<BlogImage> savedImages = saveImagesForBlog
                        (nonEmptyFiles.toArray(new MultipartFile[0]));
                savedImages.forEach(image -> image.setBlog(blogs));
                blogs.getThumbnailUrl().addAll(savedImages);
            }
        }
        return blogRepository.save(blogs);
    }
    private List<BlogImage> saveImagesForBlog(MultipartFile[] images) throws IOException {
        return Arrays.stream(images)
                .map(image -> {
                    try {
                        String storedFileName = fileUploadAvata.storeImage(subFolder, image);
                        BlogImage blogImage = new BlogImage();
                        blogImage.setImageUrl(GlobalConstant.rootUrl + GlobalConstant.uploadFolder
                                + "/" + subFolder + "/" + storedFileName);
                        return blogImage;
                    } catch (IOException e) {
                        throw new RuntimeException("Failed to store image", e);
                    }
                })
                .collect(Collectors.toList());
    }

    public void deleteBlogById(Long id) {
        Optional<Blog> productExisting = blogRepository.findById(id);
        List<BlogImage> imagesToDelete = productExisting.get().getThumbnailUrl();
        if (imagesToDelete.size() > 0) {
            for (BlogImage image : imagesToDelete) {
                fileUploadAvata.deleteImage(image.getImageUrl().substring(GlobalConstant.rootUrl.length()));
                blogImageRepository.delete(image);
            }
        }
        blogRepository.deleteById(id);
    }


    // 1. Lấy tất cả bình luận
    public List<Comment> getAllComments() {
        return commentRepository.findAll();
    }

    // 2. Tìm bình luận theo id
    public Optional<Comment> findCommentById(Long id) {
        return commentRepository.findById(id);
    }

    // 3. Tìm tất cả bình luận của một bài blog
    public List<Comment> findCommentsByBlog(Long blogId) {
        return commentRepository.findByBlogId(blogId);
    }

    public Comment createCommentBlog(CommentDTO commentDTO) {
        // Kiểm tra blog tồn tại
        Optional<Blog> blog = blogRepository.findById(commentDTO.getBlogId());
        if (!blog.isPresent()) {
            throw new IllegalArgumentException("Bài blog không tồn tại");
        }
        // Tạo bình luận
        Comment comment = new Comment();
        comment.setBlog(blog.get());
        comment.setContent(commentDTO.getContent());
        comment.setUserId(commentDTO.getUserId());
        comment.setUserName(commentDTO.getUserName());
        comment.setIsPublished(true);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);
        comment.setParentComment(null); // Bình luận cha sẽ không có parentComment

        return commentRepository.save(comment);
    }

    public Comment createReplyBlog(CommentDTO commentDTO) {
        // Kiểm tra blog tồn tại
        Optional<Blog> blogs = blogRepository.findById(commentDTO.getBlogId());
        if (!blogs.isPresent()) {
            throw new IllegalArgumentException("Bài blog không tồn tại");
        }

        // Kiểm tra bình luận cha
        Optional<Comment> parentComment = commentRepository.findById(commentDTO.getParentCommentId());
        if (!parentComment.isPresent()) {
            throw new IllegalArgumentException("Bình luận cha không tồn tại");
        }

        // Tạo bình luận con
        Comment comment = new Comment();
        comment.setBlog(blogs.get());
        comment.setContent(commentDTO.getContent());
        comment.setUserId(commentDTO.getUserId());
        comment.setUserName(commentDTO.getUserName());
        comment.setIsPublished(true);
        comment.setParentComment(parentComment.get()); // Liên kết với bình luận cha
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(null);

        return commentRepository.save(comment);
    }
}

