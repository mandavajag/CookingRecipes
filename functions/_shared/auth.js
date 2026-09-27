// Shared auth utilities for Pages Functions

const SESSION_COOKIE_NAME = 'kitchen_session';
const SESSION_MAX_AGE = 60 * 60 * 24 * 7; // 7 days in seconds

/**
 * Verify PBKDF2 password hash
 * Format: pbkdf2-sha256$iterations$salt(base64)$hash(base64)
 */
export async function verifyPassword(password, storedHash) {
  const [algorithm, iterations, saltB64, hashB64] = storedHash.split('$');
  
  if (algorithm !== 'pbkdf2-sha256') {
    throw new Error('Unsupported hash algorithm');
  }
  
  const salt = Uint8Array.from(atob(saltB64), c => c.charCodeAt(0));
  const storedKey = Uint8Array.from(atob(hashB64), c => c.charCodeAt(0));
  
  const encoder = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    'PBKDF2',
    false,
    ['deriveBits']
  );
  
  const derivedBits = await crypto.subtle.deriveBits(
    {
      name: 'PBKDF2',
      salt: salt,
      iterations: parseInt(iterations, 10),
      hash: 'SHA-256'
    },
    keyMaterial,
    256 // 32 bytes
  );
  
  const derivedKey = new Uint8Array(derivedBits);
  
  // Constant-time comparison
  if (derivedKey.length !== storedKey.length) return false;
  let result = 0;
  for (let i = 0; i < derivedKey.length; i++) {
    result |= derivedKey[i] ^ storedKey[i];
  }
  return result === 0;
}

/**
 * Create a signed session token (HMAC-SHA256)
 */
export async function createSessionToken(userId, secret) {
  const payload = {
    userId,
    exp: Date.now() + (SESSION_MAX_AGE * 1000)
  };
  
  const payloadB64 = btoa(JSON.stringify(payload));
  const signature = await signPayload(payloadB64, secret);
  
  return `${payloadB64}.${signature}`;
}

/**
 * Verify and decode session token
 */
export async function verifySessionToken(token, secret) {
  if (!token) return null;
  
  const [payloadB64, signature] = token.split('.');
  if (!payloadB64 || !signature) return null;
  
  const expectedSig = await signPayload(payloadB64, secret);
  
  // Constant-time comparison for signature
  if (signature.length !== expectedSig.length) return null;
  let result = 0;
  for (let i = 0; i < signature.length; i++) {
    result |= signature.charCodeAt(i) ^ expectedSig.charCodeAt(i);
  }
  if (result !== 0) return null;
  
  try {
    const payload = JSON.parse(atob(payloadB64));
    if (payload.exp < Date.now()) return null;
    return payload;
  } catch {
    return null;
  }
}

/**
 * Sign payload with HMAC-SHA256
 */
async function signPayload(payload, secret) {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(payload)
  );
  
  return btoa(String.fromCharCode(...new Uint8Array(signature)));
}

/**
 * Get session from request cookies
 */
export function getSessionCookie(request) {
  const cookieHeader = request.headers.get('Cookie') || '';
  const cookies = Object.fromEntries(
    cookieHeader.split(';').map(c => {
      const [key, ...v] = c.trim().split('=');
      return [key, v.join('=')];
    })
  );
  return cookies[SESSION_COOKIE_NAME];
}

/**
 * Create Set-Cookie header for session
 */
export function createSessionCookie(token) {
  return `${SESSION_COOKIE_NAME}=${token}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=${SESSION_MAX_AGE}`;
}

/**
 * Create Set-Cookie header to clear session
 */
export function clearSessionCookie() {
  return `${SESSION_COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0`;
}

/**
 * Get authenticated user from request
 */
export async function getAuthenticatedUser(request, env) {
  const token = getSessionCookie(request);
  if (!token) return null;
  
  const secret = env.SESSION_SECRET;
  if (!secret) return null;
  
  const session = await verifySessionToken(token, secret);
  if (!session) return null;
  
  // Look up user in DB
  const user = await env.DB.prepare(
    'SELECT id, email, created_at FROM users WHERE id = ?'
  ).bind(session.userId).first();
  
  return user;
}

/**
 * JSON response helper
 */
export function jsonResponse(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...headers
    }
  });
}

/**
 * Error response helper
 */
export function errorResponse(message, status = 400) {
  return jsonResponse({ error: message }, status);
}
