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

  const deepseekApiKey = process.env.DEEPSEEK_API_KEY;
  // Dikunci: hanya DeepSeek-V4.1-Flash, tanpa opsi model lain.
  const deepseekModel = 'deepseek-flash';

  if (deepseekApiKey) {
    try {
      const response = await fetch(
        'https://api.deepseek.com/chat/completions',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${deepseekApiKey}`,
          },
          body: JSON.stringify({
            model: deepseekModel,
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
            // Wajib: non-thinking mode.
            thinking: { type: 'disabled' },
            reasoning_effort: 'none',
            temperature: 0.7,
            max_tokens: 1024,
            stream: false,
          }),
        },
      );

      if (response.ok) {
        const json: any = await response.json();
        const replyText =
          json.choices?.[0]?.message?.content ||
          getKeywordFallbackReply(message);

        console.log(
          `[Chatbot] DeepSeek reply OK (model: ${deepseekModel}, thinking: disabled).`,
        );
        return res.json({
          data: { reply: replyText },
          meta: { fetchedAt: new Date().toISOString(), version: '1.0' },
        });
      }

      const errorBody = await response.text();
      console.warn(
        `[Chatbot] DeepSeek gagal (${response.status}): ${errorBody.slice(0, 300)}`,
      );
    } catch (e) {
      console.warn(
        '[Chatbot] Panggilan DeepSeek gagal, menggunakan fallback keyword.',
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
