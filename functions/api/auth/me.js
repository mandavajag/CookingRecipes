// GET /api/auth/me - Get current authenticated user

import { getAuthenticatedUser, jsonResponse, errorResponse } from '../../_shared/auth.js';

export async function onRequestGet(context) {
  const { request, env } = context;
  
  const user = await getAuthenticatedUser(request, env);
  
  if (!user) {
    return jsonResponse({ user: null });
  }
  
  return jsonResponse({
    user: {
      id: user.id,
      email: user.email,
      created_at: user.created_at
    }
  });
}
