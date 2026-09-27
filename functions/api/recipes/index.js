// GET /api/recipes - List all recipes (public)
// POST /api/recipes - Create recipe (auth required)

import { getAuthenticatedUser, jsonResponse, errorResponse } from '../../_shared/auth.js';

export async function onRequestGet(context) {
  const { env } = context;
  
  try {
    const { results } = await env.DB.prepare(`
      SELECT id, slug, title, cuisine, category, description, 
             prep_time, cook_time, servings, difficulty, tags, 
             columns, steps, notes, video_link, created_by, 
             created_at, updated_at
      FROM recipes
      ORDER BY created_at DESC
    `).all();
    
    // Parse JSON fields
    const recipes = results.map(r => ({
      ...r,
      tags: JSON.parse(r.tags || '[]'),
      columns: JSON.parse(r.columns || '[]'),
      steps: JSON.parse(r.steps || '[]')
    }));
    
    return jsonResponse(recipes);
  } catch (error) {
    console.error('Error listing recipes:', error);
    return errorResponse('Failed to load recipes', 500);
  }
}

export async function onRequestPost(context) {
  const { request, env } = context;
  
  // Check authentication
  const user = await getAuthenticatedUser(request, env);
  if (!user) {
    return errorResponse('Authentication required', 401);
  }
  
  try {
    const body = await request.json();
    
    // Validate required fields
    if (!body.title || typeof body.title !== 'string' || !body.title.trim()) {
      return errorResponse('Title is required');
    }
    
    // Generate slug from title
    const baseSlug = (body.slug || body.title)
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .substring(0, 60);
    const slug = `${baseSlug}-${Date.now().toString(36)}`;
    
    const recipe = {
      slug,
      title: body.title.trim(),
      cuisine: body.cuisine || 'Other',
      category: body.category || '',
      description: body.description || '',
      prep_time: parseInt(body.prep_time || body.prepTime, 10) || 0,
      cook_time: parseInt(body.cook_time || body.cookTime, 10) || 0,
      servings: String(body.servings || ''),
      difficulty: body.difficulty || '',
      tags: JSON.stringify(body.tags || []),
      columns: JSON.stringify(body.columns || []),
      steps: JSON.stringify(body.steps || []),
      notes: body.notes || '',
      video_link: body.video_link || body.videoLink || '',
      created_by: user.id
    };
    
    const result = await env.DB.prepare(`
      INSERT INTO recipes (slug, title, cuisine, category, description, prep_time, cook_time, 
                          servings, difficulty, tags, columns, steps, notes, video_link, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(
      recipe.slug, recipe.title, recipe.cuisine, recipe.category, recipe.description,
      recipe.prep_time, recipe.cook_time, recipe.servings, recipe.difficulty,
      recipe.tags, recipe.columns, recipe.steps, recipe.notes, recipe.video_link, recipe.created_by
    ).run();
    
    return jsonResponse({ success: true, slug: recipe.slug }, 201);
  } catch (error) {
    console.error('Error creating recipe:', error);
    if (error.message?.includes('UNIQUE constraint')) {
      return errorResponse('A recipe with this slug already exists', 409);
    }
    return errorResponse('Failed to create recipe', 500);
  }
}
