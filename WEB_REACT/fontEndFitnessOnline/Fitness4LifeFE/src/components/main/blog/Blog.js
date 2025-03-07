import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom'; // import Link for navigation
import '../../../assets/css/blog.css';
import { fetchAllBlogs } from '../../../serviceToken/BlogService'; // Import service mới

const Blog = () => {
  const [blogs, setBlogs] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [loading, setLoading] = useState(true); // loading state
  const blogsPerPage = 6;

  useEffect(() => {
    // Sử dụng service thay vì gọi axios trực tiếp
    fetchAllBlogs()
      .then((response) => {
        // Đảm bảo lấy đúng dữ liệu từ response
        const data = response.data || response;
        console.log(data);
        const sortedBlogs = data.sort((a, b) => {
          const dateA = new Date(a.createdAt[0], a.createdAt[1] - 1, a.createdAt[2], a.createdAt[3], a.createdAt[4], a.createdAt[5]);
          const dateB = new Date(b.createdAt[0], b.createdAt[1] - 1, b.createdAt[2], b.createdAt[3], b.createdAt[4], b.createdAt[5]);
          return dateB - dateA; // Sort in descending order (latest first)
        });
        setBlogs(sortedBlogs);
        setLoading(false); 
      })
      .catch((error) => {
        console.error('Error fetching blog data:', error);
        setLoading(false); 
      });
  }, []);

  const formatDateTime = (createdAt) => {
    const date = new Date(createdAt[0], createdAt[1] - 1, createdAt[2], createdAt[3], createdAt[4], createdAt[5]);
    const formattedDate = date.toLocaleDateString();
    const formattedTime = date.toLocaleTimeString();
    return `${formattedDate} ${formattedTime}`;
  };

  const indexOfLastBlog = currentPage * blogsPerPage;
  const indexOfFirstBlog = indexOfLastBlog - blogsPerPage;
  const currentBlogs = blogs.slice(indexOfFirstBlog, indexOfLastBlog);

  // Add placeholders if blogs are less than a multiple of 3
  const placeholders = Array.from({ length: (3 - (currentBlogs.length % 3)) % 3 });

  const nextPage = () => {
    if (currentPage < Math.ceil(blogs.length / blogsPerPage)) {
      setCurrentPage(currentPage + 1);
    }
  };

  const prevPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
  };

  return (
    <section id="blog-container">
      <div style={{ textAlign: "center", marginTop: "50px", marginBottom: "40px" }}>
        <div href="#" className="logo-blog">
          <span className="daily-text">Daily</span> <span className="blogs-text">Blogs</span>
        </div>
      </div>

      {loading ? (
        <div className="loading-spinner" style={{ textAlign: 'center', marginTop: '50px' }}>
          <div className="spinner"></div> 
          <p>Loading...</p>
        </div>
      ) : (
        <div className="blog-list">
          {currentBlogs.map((blog) => (
            <div key={blog.id} className="blog-item">
              <div className="blog-thumbnail-container">
                <img
                  src={blog.thumbnailUrl && blog.thumbnailUrl.length > 0 
                    ? blog.thumbnailUrl[0].imageUrl 
                    : 'https://placehold.co/300x200?text=No+Image'}
                  alt={blog.title}
                  className="blog-thumbnail"
                  onError={(e) => {
                    e.target.onerror = null;
                    e.target.src = 'https://placehold.co/300x200?text=No+Image';
                  }}
                />
              </div>
              <div className="blog-content">
                <h3>
                  <Link to={`/blog/${blog.id}`}>{blog.title}</Link>
                </h3>
                <p>{blog.content.substring(0, 150)}...</p>
                <p><strong>Category:</strong> <span className="blog-category">{blog.category}</span></p>
                <div className="blog-tags">
                  {blog.tags.split(',').map((tag, index) => (
                    <span key={index} className="blog-tag">{tag.trim()}</span>
                  ))}
                </div>
                <p className="blog-date">{formatDateTime(blog.createdAt)}</p>
                <div className="blog-stats">
                  <span className="blog-likes">{blog.likesCount} Likes</span>
                  <span className="blog-views">{blog.viewCount} Views</span>
                </div>
              </div>
            </div>
          ))}
          {placeholders.map((_, index) => (
            <div key={`placeholder-${index}`} className="blog-item placeholder"></div>
          ))}
        </div>
      )}

      <div className="pagination" style={{ textAlign: 'center', marginTop: '20px' }}>
        <button onClick={prevPage} disabled={currentPage === 1}>
          Previous
        </button>
        <span style={{ margin: '0 15px', fontSize: '18px', fontWeight: 'bold' }}>
          Page {currentPage} of {Math.ceil(blogs.length / blogsPerPage)}
        </span>
        <button onClick={nextPage} disabled={currentPage >= Math.ceil(blogs.length / blogsPerPage)}>
          Next
        </button>
      </div>
    </section>
  );
};

export default Blog;
