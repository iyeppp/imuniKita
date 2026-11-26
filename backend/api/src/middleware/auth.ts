import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase_admin_placeholder';

export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email?: string;
  };
}

let firebaseAdminApp: any = null;

export function initializeFirebaseAdmin() {
  try {
    const adminModule = require('firebase-admin');
    if (!adminModule.apps.length) {
      adminModule.initializeApp();
    }
    firebaseAdminApp = adminModule;
    console.log('[AuthMiddleware] Firebase Admin SDK berhasil diinisialisasi.');
  } catch (e) {
    console.warn(
      '[AuthMiddleware] Firebase Admin SDK tidak terinisialisasi (Service Account belum dipasang). Mode demo aktif.',
    );
  }
}

export async function requireAuth(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Header Authorization Bearer token diperlukan.',
      },
    });
  }

  const token = authHeader.split('Bearer ')[1].trim();

  if (!token) {
    return res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Token autentikasi kosong.',
      },
    });
  }

  try {
    if (firebaseAdminApp && firebaseAdminApp.apps.length > 0) {
      const decodedToken = await firebaseAdminApp.auth().verifyIdToken(token);
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
      };
    } else {
      // Fallback mode lokal tanpa service account: ekstrak payload / terima token
      req.user = {
        uid: 'user-demo-local',
        email: 'user@imunikita.app',
      };
    }
    next();
  } catch (error) {
    return res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Token Firebase ID tidak valid atau kadaluarsa.',
      },
    });
  }
}
