import * as Sentry from '@sentry/node';

// توليد معرف فريد لكل خطأ
export function generateErrorId(): string {
  return Math.random().toString(36).substring(2, 10);
}

// إرسال الخطأ ومعرفه إلى خدمة التتبع
export function logError(message: string, errorId: string, error?: unknown): void {
  Sentry.captureException(error instanceof Error ? error : new Error(String(error)), {
    tags: { errorId },
    extra: { message },
  });
}

// معالجة الأخطاء العامة وإرجاع رسالة للمستخدم تحتوي على المعرف
export function handleError(error: unknown): { errorId: string; userMessage: string } {
  const message = error instanceof Error ? error.message : String(error);
  const errorId = generateErrorId();
  logError(message, errorId, error);

  const userMessage = `حدث خطأ غير متوقع. الرجاء مشاركة هذا المعرف مع فريق الدعم: ${errorId}`;
  console.error(userMessage);
  return { errorId, userMessage };
}
