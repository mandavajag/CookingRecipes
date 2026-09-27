// POST /api/auth/logout - Clear session

import { clearSessionCookie, jsonResponse } from '../../_shared/auth.js';

export async function onRequestPost() {
  const cookie = clearSessionCookie();
  
  return jsonResponse(
    { success: true },
    200,
    { 'Set-Cookie': cookie }
  );
}
