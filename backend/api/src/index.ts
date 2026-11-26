import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { requireAuth, initializeFirebaseAdmin } from './middleware/auth.js';
import educationRouter from './routes/education.js';
import faskesRouter from './routes/faskes.js';
import chatbotRouter from './routes/chatbot.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Inisialisasi Firebase Admin jika service account dipasang
initializeFirebaseAdmin();

// Healthcheck endpoint (B8-1)
app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes terlindungi (B8-2 s/d B8-4)
app.use('/v1/education', requireAuth as any, educationRouter);
app.use('/v1/faskes', requireAuth as any, faskesRouter);
app.use('/v1/chatbot', requireAuth as any, chatbotRouter);

app.listen(PORT, () => {
  console.log(`[ImuniKita REST API] Server berjalan di http://localhost:${PORT}`);
});
