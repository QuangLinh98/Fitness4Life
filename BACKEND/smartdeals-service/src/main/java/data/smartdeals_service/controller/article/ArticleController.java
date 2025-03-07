package data.smartdeals_service.controller.article;

import data.smartdeals_service.dto.article.ArticleGenerationRequest;
import data.smartdeals_service.dto.article.ArticleGenerationResponse;
import data.smartdeals_service.services.articleService.ArticleService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/deal/articles")
class ArticleController {

    private final ArticleService articleService;

    public ArticleController(ArticleService articleService) {
        this.articleService = articleService;
    }

    @PostMapping("/generate")
    public ArticleGenerationResponse generateArticle(@RequestBody ArticleGenerationRequest request) {
        return articleService.generateArticle(request);
    }

    @PutMapping("/edit")
    public ArticleGenerationResponse editArticle(@RequestBody ArticleGenerationResponse article) {
        // Calculate the metrics again for the edited content
        return articleService.calculateMetrics(article);
    }
}