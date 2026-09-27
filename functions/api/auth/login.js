// POST /api/auth/login - Authenticate user

import { 
  verifyPassword, 
  createSessionToken, 
  createSessionCookie, 
  jsonResponse, 
  errorResponse 
} from '../../_shared/auth.js';

export async function onRequestPost(context) {
  const { request, env } = context;
  
  const secret = env.SESSION_SECRET;
  if (!secret) {
    console.error('SESSION_SECRET not configured');
    return errorResponse('Server configuration error', 500);
  }
  
  try {
    const body = await request.json();
    const { email, password } = body;
    
    if (!email || !password) {
      return errorResponse('Email and password are required');
    }
    
    // Look up user
    const user = await env.DB.prepare(
      'SELECT id, email, password_hash FROM users WHERE email = ?'
    ).bind(email.toLowerCase().trim()).first();
    
    if (!user) {
      // Use same error for security (don't reveal if email exists)
      return errorResponse('Invalid email or password', 401);
    }
    
    // Verify password
    const valid = await verifyPassword(password, user.password_hash);
    if (!valid) {
      return errorResponse('Invalid email or password', 401);
    }
    
    // Create session token
    const token = await createSessionToken(user.id, secret);
    const cookie = createSessionCookie(token);
    
    return jsonResponse(
      { 
        success: true, 
        user: { 
          id: user.id, 
          email: user.email 
        } 
      },
      200,
      { 'Set-Cookie': cookie }
    );
  } catch (error) {
    console.error('Login error:', error);
    return errorResponse('Login failed', 500);
  }
}
