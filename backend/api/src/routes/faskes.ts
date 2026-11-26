import { Router, Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth.js';
import faskesData from '../data/faskes.json' assert { type: 'json' };

const router = Router();

router.get('/', (req: AuthenticatedRequest, res: Response) => {
  const { kota, tipe } = req.query;
  let result = faskesData;

  if (kota && typeof kota === 'string' && kota.trim() !== '') {
    result = result.filter(
      (f) => f.kota.toLowerCase() === kota.toLowerCase(),
    );
  }

  if (tipe && typeof tipe === 'string' && tipe !== 'Semua') {
    result = result.filter((f) => f.tipe === tipe);
  }

  res.json({
    data: result,
    meta: {
      fetchedAt: new Date().toISOString(),
      version: '1.0',
    },
  });
});

export default router;
