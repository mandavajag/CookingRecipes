// GET /api/recipes/:slug - Get recipe by slug (public)
// PUT /api/recipes/:slug - Update recipe (owner only)
// DELETE /api/recipes/:slug - Delete recipe (owner only)

import { getAuthenticatedUser, jsonResponse, errorResponse } from '../../_shared/auth.js';

export async function onRequestGet(context) {
  const { env, params } = context;
  const slug = params.slug;
  
  try {
    const recipe = await env.DB.prepare(`
      SELECT id, slug, title, cuisine, category, description, 
             prep_time, cook_time, servings, difficulty, tags, 
             columns, steps, notes, video_link, created_by, 
             created_at, updated_at
      FROM recipes
      WHERE slug = ? OR id = ?
    `).bind(slug, slug).first();
    
    if (!recipe) {
      return errorResponse('Recipe not found', 404);
    }
    
    // Parse JSON fields
    const result = {
      ...recipe,
      tags: JSON.parse(recipe.tags || '[]'),
      columns: JSON.parse(recipe.columns || '[]'),
      steps: JSON.parse(recipe.steps || '[]')
    };
    
    return jsonResponse(result);
  } catch (error) {
    console.error('Error fetching recipe:', error);
    return errorResponse('Failed to load recipe', 500);
  }
}

export async function onRequestPut(context) {
  const { request, env, params } = context;
  const slug = params.slug;
  
  // Check authentication
  const user = await getAuthenticatedUser(request, env);
  if (!user) {
    return errorResponse('Authentication required', 401);
  }
  
  try {
    // Get existing recipe
    const existing = await env.DB.prepare(
      'SELECT id, created_by FROM recipes WHERE slug = ? OR id = ?'
    ).bind(slug, slug).first();
    
    if (!existing) {
      return errorResponse('Recipe not found', 404);
    }
    
    // Check ownership
    if (existing.created_by && existing.created_by !== user.id) {
      return errorResponse('You can only edit your own recipes', 403);
    }
    
    const body = await request.json();
    
    // Build update query
    const updates = [];
    const values = [];
    
    if (body.title !== undefined) {
      updates.push('title = ?');
      values.push(body.title.trim());
    }
    if (body.cuisine !== undefined) {
      updates.push('cuisine = ?');
      values.push(body.cuisine);
    }
    if (body.category !== undefined) {
      updates.push('category = ?');
      values.push(body.category);
    }
    if (body.description !== undefined) {
      updates.push('description = ?');
      values.push(body.description);
    }
    if (body.prep_time !== undefined || body.prepTime !== undefined) {
      updates.push('prep_time = ?');
      values.push(parseInt(body.prep_time || body.prepTime, 10) || 0);
    }
    if (body.cook_time !== undefined || body.cookTime !== undefined) {
      updates.push('cook_time = ?');
      values.push(parseInt(body.cook_time || body.cookTime, 10) || 0);
    }
    if (body.servings !== undefined) {
      updates.push('servings = ?');
      values.push(String(body.servings));
    }
    if (body.difficulty !== undefined) {
      updates.push('difficulty = ?');
      values.push(body.difficulty);
    }
    if (body.tags !== undefined) {
      updates.push('tags = ?');
      values.push(JSON.stringify(body.tags));
    }
    if (body.columns !== undefined) {
      updates.push('columns = ?');
      values.push(JSON.stringify(body.columns));
    }
    if (body.steps !== undefined) {
      updates.push('steps = ?');
      values.push(JSON.stringify(body.steps));
    }
    if (body.notes !== undefined) {
      updates.push('notes = ?');
      values.push(body.notes);
    }
    if (body.video_link !== undefined || body.videoLink !== undefined) {
      updates.push('video_link = ?');
      values.push(body.video_link || body.videoLink || '');
    }
    
    if (updates.length === 0) {
      return errorResponse('No fields to update');
    }
    
    updates.push("updated_at = datetime('now')");
    values.push(existing.id);
    
    await env.DB.prepare(`
      UPDATE recipes SET ${updates.join(', ')} WHERE id = ?
    `).bind(...values).run();
    
    return jsonResponse({ success: true });
  } catch (error) {
    console.error('Error updating recipe:', error);
    return errorResponse('Failed to update recipe', 500);
  }
}

export async function onRequestDelete(context) {
  const { request, env, params } = context;
  const slug = params.slug;
  
  // Check authentication
  const user = await getAuthenticatedUser(request, env);
  if (!user) {
    return errorResponse('Authentication required', 401);
  }
  
  try {
    // Get existing recipe
    const existing = await env.DB.prepare(
      'SELECT id, created_by FROM recipes WHERE slug = ? OR id = ?'
    ).bind(slug, slug).first();
    
    if (!existing) {
      return errorResponse('Recipe not found', 404);
    }
    
    // Check ownership
    if (existing.created_by && existing.created_by !== user.id) {
      return errorResponse('You can only delete your own recipes', 403);
    }
    
    await env.DB.prepare('DELETE FROM recipes WHERE id = ?').bind(existing.id).run();
    
    return jsonResponse({ success: true });
  } catch (error) {
    console.error('Error deleting recipe:', error);
    return errorResponse('Failed to delete recipe', 500);
  }
}
