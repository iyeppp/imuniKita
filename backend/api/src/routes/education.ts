import { Router, Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth.js';
import articlesData from '../data/articles.json' assert { type: 'json' };
import videosData from '../data/videos.json' assert { type: 'json' };
import quizzesData from '../data/quizzes.json' assert { type: 'json' };

const router = Router();

router.get('/articles', (req: AuthenticatedRequest, res: Response) => {
  const { kategori } = req.query;
  let articles = articlesData;

  if (kategori && typeof kategori === 'string' && kategori !== 'Semua') {
    articles = articlesData.filter((a) => a.kategori === kategori);
  }

  res.json({
    data: articles,
    meta: {
      fetchedAt: new Date().toISOString(),
      version: '1.0',
    },
  });
});

router.get('/videos', (req: AuthenticatedRequest, res: Response) => {
  const { kategori } = req.query;
  let videos = videosData;

  if (kategori && typeof kategori === 'string' && kategori !== 'Semua') {
    videos = videosData.filter((v) => v.kategori === kategori);
  }

  res.json({
    data: videos,
    meta: {
      fetchedAt: new Date().toISOString(),
      version: '1.0',
    },
  });
});

router.get('/quizzes', (req: AuthenticatedRequest, res: Response) => {
  res.json({
    data: quizzesData,
    meta: {
      fetchedAt: new Date().toISOString(),
      version: '1.0',
    },
  });
});

export default router;
