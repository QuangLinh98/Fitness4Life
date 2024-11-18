package data.smartdeals_service.services;
import data.smartdeals_service.dto.CreateBlogDTO;
import data.smartdeals_service.dto.UpdateBlogDTO;
import data.smartdeals_service.helpers.FileUploadAvata;
import data.smartdeals_service.helpers.GlobalConstant;
import data.smartdeals_service.models.Blog;
import data.smartdeals_service.models.BlogImage;
import data.smartdeals_service.repository.BlogImageRepository;
import data.smartdeals_service.repository.BlogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BlogService {
    private final BlogRepository blogRepository;
    private final BlogImageRepository blogImageRepository;

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
        blog.setAuthorId(createBlogDTO.getAuthorId());
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

        if(updateBlogDTO.getThumbnailUrl() != null && !updateBlogDTO.getDeleteImageUrl().isEmpty()) {
            List<BlogImage> imagesToDelete = blogs.getThumbnailUrl().stream()
                    .filter(image -> updateBlogDTO.getDeleteImageUrl()
                            .contains(image.getId()))
                    .collect(Collectors.toList());

            for (BlogImage image : imagesToDelete) {
                fileUploadAvata.deleteImage(image.getImageUrl());
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
}

