import { Router, Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth.js';

const router = Router();

// In-memory rate limiting per user ID (max 20 requests/minute)
const userRequestCounts = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(uid: string): boolean {
  const now = Date.now();
  const userRate = userRequestCounts.get(uid);

  if (!userRate || now > userRate.resetAt) {
    userRequestCounts.set(uid, { count: 1, resetAt: now + 60000 });
    return true;
  }

  if (userRate.count >= 20) {
    return false;
  }

  userRate.count += 1;
  return true;
}

// Fallback keyword matcher (31+ aturan kata kunci ImuniKita)
function getKeywordFallbackReply(message: string): string {
  const query = message.toLowerCase();

  if (query.containsAny(['demam', 'panas', 'kipi'])) {
    return 'Reaksi demam ringan setelah imunisasi DPT/Campak adalah hal wajar. Berikan ASI/cairan secukupnya, kenakan pakaian tipis, dan berikan parasetamol sesuai dosis dokter bila suhu > 38,5°C.';
  }

  if (query.containsAny(['vaksin', 'imunisasi', 'jadwal'])) {
    return 'Imunisasi dasar wajib bayi meliputi Hepatitis B (0 bulan), BCG (1 bulan), DPT-HB-Hib 1-3 & Polio 1-4 (2, 3, 4 bulan), serta Campak/MR (9 bulan). Anda dapat melihat jadwal lengkap di menu Imunisasi.';
  }

  if (query.containsAny(['mpasi', 'makan', 'nutrisi'])) {
    return 'MPASI mulai diberikan saat bayi berusia 6 bulan. Awali dengan tekstur puree halus 2 kali sehari, porsi 2-3 sendok makan, mencakup karbohidrat, protein hewani, dan lemak tambahan.';
  }

  if (query.containsAny(['faskes', 'puskesmas', 'rumah sakit', 'klinik'])) {
    return 'Anda dapat menemukan fasilitas kesehatan terdekat (Puskesmas, RS, Klinik, Apotek) melalui menu Direktori Faskes di aplikasi ImuniKita.';
  }

  return 'Halo! Saya asisten ImuniKita. Saya siap membantu menjawab pertanyaan Anda seputar jadwal imunisasi anak, penanganan KIPI/demam, nutrisi MPASI, dan rekomendasi faskes terdekat.';
}

declare global {
  interface String {
    containsAny(keywords: string[]): boolean;
  }
}

String.prototype.containsAny = function (keywords: string[]): boolean {
  return keywords.some((k) => this.includes(k));
};

router.post('/messages', async (req: AuthenticatedRequest, res: Response) => {
  const uid = req.user?.uid || 'anonymous';

  if (!checkRateLimit(uid)) {
    return res.status(429).json({
      error: {
        code: 'TOO_MANY_REQUESTS',
        message: 'Batas pesan terlampaui (maksimal 20 pesan per menit). Silakan tunggu sejenak.',
      },
    });
  }

  const { message } = req.body;

  if (!message || typeof message !== 'string' || message.trim() === '') {
    return res.status(400).json({
      error: {
        code: 'BAD_REQUEST',
        message: 'Pesan tidak boleh kosong.',
      },
    });
  }

  const groqApiKey = process.env.GROQ_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

  if (groqApiKey) {
    try {
      const response = await fetch(
        'https://api.groq.com/openai/v1/chat/completions',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${groqApiKey}`,
          },
          body: JSON.stringify({
            model: 'llama-3.3-70b-versatile',
            messages: [
              {
                role: 'system',
                content:
                  'Anda adalah asisten kesehatan anak ramah ImuniKita. Jawab pertanyaan ibu/orang tua dengan ringkas, empati, dan akurat medis dalam Bahasa Indonesia.',
              },
              {
                role: 'user',
                content: message,
              },
            ],
            temperature: 0.7,
          }),
        },
      );

      if (response.ok) {
        const json: any = await response.json();
        const replyText =
          json.choices?.[0]?.message?.content ||
          getKeywordFallbackReply(message);

        return res.json({
          data: { reply: replyText },
          meta: { fetchedAt: new Date().toISOString(), version: '1.0' },
        });
      }
    } catch (e) {
      console.warn(
        '[Chatbot] Panggilan Groq LLM gagal, mencoba fallback keyword.',
      );
    }
  } else if (geminiApiKey) {
    try {
      // Panggilan LLM (Gemini API)
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                role: 'user',
                parts: [
                  {
                    text: `Anda adalah asisten kesehatan anak ramah ImuniKita. Jawab pertanyaan ibu/orang tua berikut dengan ringkas, empati, dan akurat medis:\n\n${message}`,
                  },
                ],
              },
            ],
          }),
        },
      );

      if (response.ok) {
        const json: any = await response.json();
        const replyText =
          json.candidates?.[0]?.content?.parts?.[0]?.text ||
          getKeywordFallbackReply(message);

        return res.json({
          data: { reply: replyText },
          meta: { fetchedAt: new Date().toISOString(), version: '1.0' },
        });
      }
    } catch (e) {
      console.warn(
        '[Chatbot] Panggilan Gemini LLM gagal, menggunakan fallback keyword.',
      );
    }
  }

  // Fallback ke keyword matcher jika LLM API Key belum diisi atau gagal
  const reply = getKeywordFallbackReply(message);
  return res.json({
    data: { reply },
    meta: { fetchedAt: new Date().toISOString(), version: '1.0' },
  });
});

export default router;
