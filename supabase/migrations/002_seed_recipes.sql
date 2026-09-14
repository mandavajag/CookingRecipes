-- Seed existing recipes from recipes.json
-- 
-- OWNERSHIP NOTE:
-- These recipes are inserted with created_by = NULL (no owner).
-- This makes them "community/system" recipes with the following behavior:
--   - Readable by everyone (anon + authenticated) via SELECT policy
--   - NOT editable by any regular user (RLS requires auth.uid() = created_by)
--   - Only modifiable via service_role key (admin/backend only)
--
-- This is intentional: seed data represents community content that users can
-- browse but not modify. User-created recipes will have proper ownership.
--
-- To transfer ownership of a seed recipe to a specific user (e.g., an admin):
--   UPDATE recipes SET created_by = 'user-uuid-here' WHERE slug = 'recipe-slug';
-- (Must be run with service_role key, not anon/authenticated)

INSERT INTO public.recipes (slug, title, cuisine, category, prep_time, cook_time, servings, difficulty, tags, columns, steps, notes, video_link, created_by)
VALUES

-- Punjabi Masala Fried Chicken
(
  'punjabi-masala-fried-chicken',
  'Punjabi Masala Fried Chicken (Village Style)',
  'Indian',
  'Chicken',
  30,
  35,
  '4',
  'Medium',
  ARRAY['chicken', 'punjabi', 'masala', 'thighs', 'roti'],
  '[
    {"title": "Marinade", "items": [
      {"qty": "1 kg", "name": "chicken thighs, medium pieces"},
      {"qty": "1 tsp", "name": "turmeric powder"},
      {"qty": "1 tbsp", "name": "ginger-garlic paste"},
      {"qty": "1 tsp", "name": "salt"},
      {"qty": "1 tbsp", "name": "lemon juice / vinegar"}
    ]},
    {"title": "Masala Base", "items": [
      {"qty": "3 tbsp", "name": "oil"},
      {"qty": "1 small cube", "name": "butter"},
      {"qty": "2 large", "name": "red onions, finely chopped"},
      {"qty": "1 tbsp", "name": "chopped garlic"},
      {"qty": "1 tbsp", "name": "chopped ginger"},
      {"qty": "2–3", "name": "green chilies, finely chopped"},
      {"qty": "1 cup", "name": "coriander leaves, finely chopped (divided)"},
      {"qty": "2 large", "name": "tomatoes, finely chopped"},
      {"qty": "~1 cup", "name": "warm water (for cooking chicken)"}
    ]},
    {"title": "Spice Powders", "items": [
      {"qty": "1 tsp", "name": "Kashmiri red chili powder (color)"},
      {"qty": "1 tsp", "name": "red chili powder / paprika (heat)"},
      {"qty": "1 tbsp", "name": "coriander powder"},
      {"qty": "1 tsp", "name": "cumin powder"},
      {"qty": "1 tsp", "name": "garam masala"},
      {"qty": "1/2 tsp", "name": "cracked black pepper"},
      {"qty": "1 tsp", "name": "kasoori methi (dried fenugreek)"},
      {"qty": "1/2 tsp", "name": "turmeric powder"},
      {"qty": "to taste", "name": "salt"}
    ]},
    {"title": "Finish", "items": [
      {"qty": "2–3", "name": "green chilies, sliced"},
      {"qty": "handful", "name": "fresh coriander, chopped"},
      {"qty": "few strips", "name": "ginger, julienned"},
      {"qty": "1 tsp", "name": "butter"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Marinate thighs with turmeric, salt, ginger-garlic, lemon. Rest 20–30 min.',
    'Heat oil + butter. Fry onions 2–3 min on medium until light golden (not fully browned).',
    'Add chopped garlic, green chilies, half the coriander. Fry 1 min.',
    'Stir in both chili powders, coriander, cumin, black pepper, kasoori methi, turmeric, garam masala — 30 sec so spices roast, don''t burn.',
    'Add tomatoes; cook until mushy and oil separates. Splash of water if needed. This is the Punjabi curry base.',
    'Add chicken; coat and sear 3–4 min. Add warm water almost covering (~1 cup). Low heat, cover 12–15 min.',
    'Bhunao: lid off, high flame 4–5 min to dry excess water — thick clinging masala, not gravy.',
    'Finish with sliced green chilies, lots of coriander, ginger julienne, knob of butter. Serve hot with roti / naan.'
  ],
  'Don''t fully brown the onions — light golden only. Bhunao is the ''fried'' part: dry it until masala coats. Proper rustic, village energy.',
  'https://www.facebook.com/share/v/1DdPnzc6PS/?mibextid=wwXIfr',
  NULL
),

-- Cajun Chicken Pasta
(
  'cajun-chicken-pasta',
  'Cajun Chicken Pasta (Creamy Rigatoni Meal Prep)',
  'American',
  'Pasta',
  15,
  30,
  '6',
  'Easy',
  ARRAY['pasta', 'chicken', 'cajun', 'meal-prep', 'creamy', 'one-pan'],
  '[
    {"title": "Chicken & Seasoning", "items": [
      {"qty": "~1.5 lb", "name": "chicken breasts (3–4), flattened then cubed"},
      {"qty": "1 tsp", "name": "kosher salt"},
      {"qty": "1 tsp", "name": "onion powder"},
      {"qty": "1 tsp", "name": "garlic powder"},
      {"qty": "1 tbsp", "name": "paprika"},
      {"qty": "1 tsp", "name": "Italian seasoning"},
      {"qty": "1 tbsp", "name": "Cajun seasoning"},
      {"qty": "spray", "name": "olive oil"}
    ]},
    {"title": "Veggies & Pasta", "items": [
      {"qty": "1", "name": "red bell pepper, diced"},
      {"qty": "1", "name": "orange bell pepper, diced"},
      {"qty": "1 medium", "name": "white onion, diced"},
      {"qty": "2 tsp", "name": "minced garlic"},
      {"qty": "12 oz", "name": "dry rigatoni / ziti (~3 cups dry)"},
      {"qty": "32 oz", "name": "reduced-sodium chicken broth (1 carton)"},
      {"qty": "~1 cup", "name": "water (to just cover pasta)"}
    ]},
    {"title": "Creamy Finish", "items": [
      {"qty": "8 oz", "name": "1/3 less fat cream cheese (1 block)"},
      {"qty": "1/2 cup", "name": "shredded Parmesan or Italian blend"},
      {"qty": "pinch", "name": "salt to taste after"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Flatten breasts, cube bite-size. Season with salt, onion powder, garlic powder, paprika, Italian seasoning, Cajun. Mix by hand.',
    'Oil a hot skillet. Sear chicken until browned, ~5–6 min.',
    'Add diced peppers and onion; stir. Add minced garlic; stir.',
    'Add dry rigatoni. Pour in broth + ~1 cup water until pasta is just covered. Pinch of salt. Bring to boil.',
    'Cover, simmer 12–15 min, stirring once, until pasta is tender and most liquid is absorbed.',
    'Lower heat. Stir in cream cheese block + shredded cheese until melted into a thick orange creamy sauce.',
    'Scoop into 6 bowls. Fridge 4–5 days; reheat with a splash of water or broth.'
  ],
  'One-pan meal prep. Pasta should be just covered — not swimming. Cream cheese melts into the residual broth; stir until glossy and coated.',
  'https://www.facebook.com/share/v/1DNCxWytGV/?mibextid=wwXIfr',
  NULL
),

-- Street Corn Bowl
(
  'street-corn-chicken-rice-bowl',
  'Street Corn Bowl | 55g Protein',
  'Mexican',
  'Bowl',
  20,
  30,
  '5',
  'Easy',
  ARRAY['bowl', 'high-protein', 'meal-prep', 'chicken', 'elote', 'rice'],
  '[
    {"title": "Chicken", "items": [
      {"qty": "~1.5 lb", "name": "chicken breasts (3 large)"},
      {"qty": "1 tbsp", "name": "chili powder"},
      {"qty": "1 tbsp", "name": "smoked paprika"},
      {"qty": "1 tsp", "name": "cumin"},
      {"qty": "1 tsp", "name": "garlic powder"},
      {"qty": "1 tsp", "name": "onion powder"},
      {"qty": "1/2 tsp", "name": "black pepper"},
      {"qty": "1/2 tsp", "name": "salt"},
      {"qty": "spray", "name": "olive oil"}
    ]},
    {"title": "Elote Salad", "items": [
      {"qty": "2 cans (15 oz)", "name": "sweet corn, drained"},
      {"qty": "1 cup", "name": "plain non-fat Greek yogurt"},
      {"qty": "2–3 tbsp", "name": "light mayo"},
      {"qty": "3/4–1 cup", "name": "crumbled Cotija"},
      {"qty": "1/2 large", "name": "red onion, finely diced"},
      {"qty": "1–2", "name": "jalapeños, finely diced"},
      {"qty": "handful", "name": "cilantro, chopped"},
      {"qty": "2", "name": "limes, juiced"},
      {"qty": "to taste", "name": "kosher salt, chili powder, Tajín (1–2 tbsp)"}
    ]},
    {"title": "Base & Serve", "items": [
      {"qty": "3–4 cups", "name": "cooked white rice (~3/4 cup per bowl)"},
      {"qty": "to finish", "name": "extra Tajín"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Flatten chicken slightly for even cooking. Coat in chili powder, smoked paprika, cumin, garlic, onion powder, salt, pepper.',
    'Cook in a hot skillet/electric pan with oil spray, lid on medium-high, ~6–7 min per side until charred and 165°F. Rest, cube.',
    'Elote: mix corn, Greek yogurt, mayo, Cotija, red onion. Fold in jalapeño, cilantro, lime. Season with salt, chili powder, 1–2 tbsp Tajín until creamy.',
    'Assemble 5 bowls: rice → chicken → big scoop of street corn → more Tajín on top.',
    'Fridge 4–5 days.'
  ],
  'Same elote vibe as the pasta salad / sweet potato bowls, but rice base. Flatten chicken for even sear. 55g protein per bowl as labeled in the reel.',
  'https://www.facebook.com/share/r/1Bhkd2wzrz/?mibextid=wwXIfr',
  NULL
),

-- Elote Chicken Pasta Salad
(
  'elote-chicken-pasta-salad',
  '51g Protein Elote Chicken Pasta Salad',
  'Mexican',
  'Salad',
  20,
  30,
  '5',
  'Easy',
  ARRAY['pasta', 'high-protein', 'meal-prep', 'chicken', 'elote', 'cold'],
  '[
    {"title": "Protein", "items": [
      {"qty": "1.5–2 lb", "name": "chicken breasts (2–3 large)"},
      {"qty": "generous", "name": "chili powder, smoked paprika, garlic powder, onion powder, cumin, salt + pepper"}
    ]},
    {"title": "Pasta & Corn", "items": [
      {"qty": "12 oz", "name": "dry tri-color rotini (1 box)"},
      {"qty": "3 cups", "name": "corn kernels (frozen or drained canned)"}
    ]},
    {"title": "Fresh Mix", "items": [
      {"qty": "1/2 large", "name": "red onion, diced"},
      {"qty": "1 bunch", "name": "cilantro, chopped"},
      {"qty": "3/4 cup", "name": "crumbled Cotija or queso fresco"},
      {"qty": "2", "name": "limes, juiced"}
    ]},
    {"title": "Creamy Sauce", "items": [
      {"qty": "1/2 cup", "name": "plain Greek yogurt"},
      {"qty": "1/4 cup", "name": "light mayo"},
      {"qty": "1 tbsp", "name": "Tajín (+ more for topping)"},
      {"qty": "1 tsp", "name": "chili powder / paprika"},
      {"qty": "1/2 tsp", "name": "cumin"},
      {"qty": "1/2 tsp", "name": "garlic powder"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Season chicken heavily both sides. Sear on a hot griddle/flat-top with oil spray until charred and 165°F inside. Rest, then dice.',
    'Boil rotini in salted water until al dente. Drain.',
    'Char corn: hot dry pan, no liquid. Sit 4–5 min until golden; stir once.',
    'Huge bowl: rotini, diced chicken, charred corn, cilantro, red onion, Cotija. Lime juice, Greek yogurt, mayo, spice mix + Tajín. Mix until creamy and coated. More Tajín on top.',
    'Divide into 5 containers. Fridge 4–5 days. Serve cold / room temp.'
  ],
  'Char on chicken + corn is the flavor. Don''t skip Tajín. Meal-prep king — 5 bowls like the reel.',
  'https://www.facebook.com/share/r/18ZqcYKfEv/?mibextid=wwXIfr',
  NULL
),

-- Loaded Sweet Potato
(
  'loaded-sweet-potato-elote',
  'Loaded Sweet Potato with Elote + Taco Beef',
  'Mexican',
  'Bowl',
  20,
  45,
  '4',
  'Easy',
  ARRAY['bowl', 'high-protein', 'meal-prep', 'sweet-potato', 'beef', 'elote'],
  '[
    {"title": "Sweet Potatoes", "items": [
      {"qty": "4 medium", "name": "sweet potatoes"},
      {"qty": "drizzle", "name": "olive oil spray / oil"},
      {"qty": "to taste", "name": "salt + black pepper"}
    ]},
    {"title": "Elote Corn Salad", "items": [
      {"qty": "3–4 cups", "name": "sweet corn kernels (thawed frozen or drained canned)"},
      {"qty": "1/4 cup", "name": "plain Greek yogurt"},
      {"qty": "2 tbsp", "name": "light mayo"},
      {"qty": "1/2 cup", "name": "crumbled Cotija cheese"},
      {"qty": "1/4 cup", "name": "red onion, finely diced"},
      {"qty": "1", "name": "jalapeño, finely diced"},
      {"qty": "handful", "name": "cilantro, chopped"},
      {"qty": "2", "name": "limes, juiced"},
      {"qty": "to taste", "name": "Tajín, chili powder, garlic powder, salt + pepper"}
    ]},
    {"title": "Taco Beef", "items": [
      {"qty": "1 lb", "name": "lean ground beef (93/7 or 96/4)"},
      {"qty": "1 tsp", "name": "cumin (or packet taco seasoning)"},
      {"qty": "1 tsp", "name": "garlic powder"},
      {"qty": "1/2 tsp", "name": "onion powder"},
      {"qty": "to taste", "name": "salt + pepper"},
      {"qty": "to serve", "name": "extra lime, cilantro, Tajín, Cotija"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Roast: halve sweet potatoes lengthwise. Oil, salt, pepper. Cut-side down on a sheet pan. Bake 425°F / 220°C for 35–45 min until soft and caramelized.',
    'Elote: mix corn, Greek yogurt, mayo, most of the Cotija, red onion, jalapeño, cilantro, lime juice. Season with Tajín, chili powder, garlic powder, salt, pepper. Taste — creamy, salty, limey, spicy.',
    'Beef: oil a pan, brown lean ground beef with cumin/garlic/onion (or taco seasoning), salt, pepper. Cook until no pink. Drain if needed.',
    'Assemble: smash one sweet potato half open in a bowl. ~4 oz beef, big scoop of corn salad. Finish with Cotija, Tajín, cilantro, lime wedge.'
  ],
  'Makes 4 bowls on one tray — meal-prep friendly. Leaner beef = higher protein. Elote should taste aggressively limey/Tajín before it hits the potato.',
  'https://www.facebook.com/share/r/1K4J37gTf7/?mibextid=wwXIfr',
  NULL
),

-- Şifa Çorbası
(
  'sifa-corbasi',
  'Şifa Çorbası (Creamy Chicken & Vegetable Soup)',
  'Turkish',
  'Soup',
  15,
  35,
  '4',
  'Easy',
  ARRAY['soup', 'high-protein', 'chicken', 'blender', 'dairy-free', 'gluten-free'],
  '[
    {"title": "Pot", "items": [
      {"qty": "700g", "name": "chicken breast (~1.5 lb / 2 large breasts)"},
      {"qty": "2 medium", "name": "potatoes, peeled and cubed (Yukon Gold if possible)"},
      {"qty": "1 large", "name": "carrot, chopped"},
      {"qty": "1 large", "name": "onion, quartered"},
      {"qty": "1", "name": "kapya / red bell pepper, sliced"},
      {"qty": "2", "name": "tomatoes, diced"},
      {"qty": "3–4", "name": "garlic cloves"},
      {"qty": "4–5 cups", "name": "hot water to cover (or bone broth)"},
      {"qty": "2–3 tbsp", "name": "olive oil (EVOO)"}
    ]},
    {"title": "Finish", "items": [
      {"qty": "to taste", "name": "salt & black pepper"},
      {"qty": "~1 tsp", "name": "turmeric"},
      {"qty": "~1 tsp", "name": "paprika / chili flake"},
      {"qty": "handful", "name": "fresh parsley, chopped"},
      {"qty": "1/2", "name": "lemon, for serving"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Layer in a large pot: potatoes, carrots, red pepper, onion, garlic, and tomatoes. Lay whole chicken breasts on top.',
    'Drizzle olive oil, pour hot water to just cover. Lid on — simmer until chicken and potatoes are fully tender, ~25–30 min.',
    'Pull chicken out with tongs; shred in a bowl with two forks.',
    'Blend remaining vegetables + broth in the pot (immersion blender) until smooth and bright orange-creamy.',
    'Return shredded chicken. Season with salt, turmeric, paprika, black pepper, and a big handful of parsley. Stir 2–3 min.',
    'Ladle into bowls and squeeze fresh lemon on top — that''s key.'
  ],
  'Creaminess is 100% from blended potato/carrot/tomato — no cream, no flour. Air-chilled chicken stays juicier. Kapya → red bell is fine. Hot water works; bone broth upgrades depth. Gluten-free, dairy-free, recovery-friendly.',
  'https://www.facebook.com/share/r/1CAoXt8yV2/?mibextid=wwXIfr',
  NULL
),

-- Pepper Chicken
(
  'pepper-chicken',
  'THE Ultimate Pepper Chicken (Ghee Roast Style)',
  'Indian',
  'Chicken',
  30,
  40,
  '4',
  'Medium',
  ARRAY['chicken', 'high-protein', 'pepper', 'one-pan', 'low-carb'],
  '[
    {"title": "Marinade", "items": [
      {"qty": "1 kg", "name": "boneless chicken thighs, washed & bite-size"},
      {"qty": "1 tbsp", "name": "chili powder / Kashmiri chili powder"},
      {"qty": "1 tbsp", "name": "coriander powder"},
      {"qty": "1/2 tsp", "name": "turmeric powder"},
      {"qty": "1 tsp", "name": "garam masala"},
      {"qty": "1 tsp", "name": "salt (adjust to taste)"},
      {"qty": "1/2 cup", "name": "thick curd / yogurt"}
    ]},
    {"title": "Cooking", "items": [
      {"qty": "2 tbsp", "name": "sesame oil (gingelly) — key for flavor"},
      {"qty": "2 large", "name": "red onions, thinly sliced"},
      {"qty": "2 sprigs", "name": "fresh curry leaves"}
    ]},
    {"title": "Fresh Pepper Powder", "items": [
      {"qty": "1.5 tbsp", "name": "fennel seeds / saunf"},
      {"qty": "2 tbsp", "name": "whole black peppercorns"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Marinate: mix chicken with chili, coriander, turmeric, garam masala, salt, and yogurt. Rest 20–30 min.',
    'Golden onions: heat sesame oil in a wide pan. Sauté sliced onions on medium until deep golden brown — don''t rush.',
    'Dum cook: add all marinated chicken on top of the onions, spread out. DO NOT STIR. Cover and cook medium-low 15 min so the chicken releases its own water.',
    'Fresh masala: meanwhile toast fennel + peppercorns dry 2–3 min until aromatic. Cool slightly, grind coarse (not super fine).',
    'Finish: uncover, add fennel-pepper powder + curry leaves. Mix. Cook uncovered 7–8 min until dark, dry, glossy, and roasty — not gravy. Adjust salt/pepper.',
    'Serve: banana leaf energy — with hot ghee rice, chapati, parotta, roti, or as a wrap.'
  ],
  'Thighs not breast. No water. No stirring for the first 15 min = caramelized onion + chicken flavor. Fresh pepper powder beats store-bought. Splash more sesame oil at the end for restaurant gloss.',
  'https://www.facebook.com/reel/894313183408917',
  NULL
),

-- Halal Cart Chicken
(
  'halal-cart',
  'Halal Cart Chicken and Rice',
  'Street',
  'Plate',
  20,
  30,
  '4',
  'Easy',
  ARRAY['chicken', 'rice', 'meal-prep', 'sauce'],
  '[
    {"title": "Chicken", "items": [
      {"qty": "1.5 lb", "name": "boneless skinless thighs, bite-size"},
      {"qty": "2 tbsp", "name": "olive oil"},
      {"qty": "1 tbsp", "name": "white vinegar"},
      {"qty": "1", "name": "lemon, juiced"},
      {"qty": "1 tsp", "name": "salt"},
      {"qty": "1/2 tsp", "name": "black pepper"},
      {"qty": "1 tsp", "name": "garlic powder"},
      {"qty": "1 tsp", "name": "turmeric"},
      {"qty": "1 tsp", "name": "paprika"},
      {"qty": "1 tsp", "name": "cumin"}
    ]},
    {"title": "Yellow Rice", "items": [
      {"qty": "2 cups", "name": "basmati, rinsed"},
      {"qty": "~3 cups", "name": "chicken stock"},
      {"qty": "1 tsp", "name": "salt"},
      {"qty": "1 tbsp", "name": "olive oil"},
      {"qty": "2 tbsp", "name": "butter"},
      {"qty": "1 tsp", "name": "turmeric"},
      {"qty": "pinch", "name": "cinnamon"},
      {"qty": "3 whole", "name": "cloves"},
      {"qty": "pinch", "name": "dried cilantro"},
      {"qty": "pinch", "name": "cumin powder"},
      {"qty": "1/2 tsp", "name": "garlic powder"}
    ]},
    {"title": "White Sauce", "items": [
      {"qty": "1/2 cup", "name": "mayo"},
      {"qty": "1/4 cup", "name": "sour cream"},
      {"qty": "1 tbsp", "name": "lemon juice"},
      {"qty": "1/2 tsp", "name": "garlic powder"},
      {"qty": "", "name": "salt & pepper"},
      {"qty": "to serve", "name": "white sauce, red hot sauce, parsley"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Marinate chicken with oil, vinegar, lemon & spices 20 min, then sear until charred and cooked through.',
    'Toast rice with oil, butter, turmeric & spices, add stock, simmer covered 15 min until fluffy.',
    'Whisk mayo, sour cream, lemon, garlic, salt & pepper; chill to thicken.',
    'Pile rice, top with chicken, drizzle both sauces, scatter parsley.'
  ],
  'Char on the chicken is the whole point — don''t crowd the pan.',
  '',
  NULL
),

-- Tomato Basil Soup
(
  'tomato-basil-soup',
  'High-Protein Tomato Basil Soup',
  'Comfort',
  'Soup',
  15,
  60,
  '3',
  'Easy',
  ARRAY['soup', 'high-protein', 'tomato', 'blender'],
  '[
    {"title": "Roast", "items": [
      {"qty": "2 cups", "name": "cherry tomatoes"},
      {"qty": "1", "name": "yellow onion, quartered"},
      {"qty": "1", "name": "red bell pepper, halved"},
      {"qty": "1 head", "name": "garlic (or 5 cloves)"},
      {"qty": "2 tbsp", "name": "olive oil"},
      {"qty": "1 tsp", "name": "salt"},
      {"qty": "1/2 tsp", "name": "black pepper"},
      {"qty": "1 tsp", "name": "onion powder"},
      {"qty": "1/2 tsp", "name": "chili flakes"},
      {"qty": "1 tsp", "name": "paprika"}
    ]},
    {"title": "Blend", "items": [
      {"qty": "2 cups", "name": "bone broth"},
      {"qty": "1 cup", "name": "cottage cheese (high protein)"},
      {"qty": "1 handful", "name": "fresh basil"},
      {"qty": "", "name": "roasted veg from sheet pan"}
    ]},
    {"title": "Garnish", "items": [
      {"qty": "drizzle", "name": "olive oil or cream"},
      {"qty": "pinch", "name": "fresh basil, chopped"},
      {"qty": "optional", "name": "parmesan"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Sheet pan tomatoes, onion, pepper, garlic with oil + spices.',
    'Roast at 400°F for 60 min till caramelized and tender.',
    'Blend roasted veg with bone broth + cottage cheese + basil till smooth and creamy.',
    'Bowl it up — oil/cream drizzle, fresh basil, parmesan optional.'
  ],
  'Roast until deeply caramelized — pale veg = flat soup.',
  'https://www.facebook.com/share/r/18xje9WN51/',
  NULL
),

-- Carbonara
(
  'carbonara',
  'Spaghetti Carbonara',
  'Italian',
  'Pasta',
  10,
  20,
  '4',
  'Medium',
  ARRAY['pasta', 'eggs', 'cheese', 'quick'],
  '[
    {"title": "Ingredients", "items": [
      {"qty": "400g", "name": "spaghetti"},
      {"qty": "200g", "name": "guanciale (or pancetta)"},
      {"qty": "3 large", "name": "eggs + 2 yolks"},
      {"qty": "100g", "name": "Pecorino Romano, finely grated"},
      {"qty": "50g", "name": "Parmigiano-Reggiano, grated"},
      {"qty": "", "name": "Freshly cracked black pepper"},
      {"qty": "", "name": "Kosher salt, for pasta water"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Bring a large pot of heavily salted water to a rolling boil.',
    'Cut guanciale into lardons. Render in a cold pan over medium-low ~8 min until crispy at edges. Keep warm off heat.',
    'Whisk eggs, yolks, and most of the cheese. Season hard with black pepper.',
    'Cook spaghetti until 90 seconds shy of al dente. Reserve 1 cup pasta water.',
    'Toss drained pasta in guanciale fat off heat.',
    'Pour egg mixture over pasta, tossing constantly. Splash pasta water until glossy. Don''t scramble.',
    'Plate warm. Finish with cheese and pepper.'
  ],
  'Off-heat is non-negotiable. Residual heat finishes the eggs.',
  '',
  NULL
),

-- Tikka Masala
(
  'tikka-masala',
  'Chicken Tikka Masala',
  'Indian',
  'Curry',
  30,
  40,
  '4',
  'Medium',
  ARRAY['chicken', 'curry', 'dinner'],
  '[
    {"title": "Ingredients", "items": [
      {"qty": "700g", "name": "boneless chicken thighs, 4cm pieces"},
      {"qty": "", "name": "Marinade: 180g yogurt, 2 tsp garam masala, 1½ tsp cumin, 1 tsp turmeric, 1 tsp Kashmiri chili, 1 tsp salt, 2 tbsp oil"},
      {"qty": "3 tbsp", "name": "ghee, 1 large onion finely diced"},
      {"qty": "", "name": "6 garlic cloves minced, 25g ginger grated"},
      {"qty": "", "name": "2 tsp cumin seeds, 1 tsp coriander seeds (toasted, ground)"},
      {"qty": "", "name": "1 tsp turmeric, 2 tsp garam masala, 1½ tsp Kashmiri chili"},
      {"qty": "400g", "name": "crushed tomatoes"},
      {"qty": "150ml", "name": "heavy cream"},
      {"qty": "", "name": "Salt, fresh cilantro"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Marinate chicken min 4 hours (overnight best).',
    'Broil/grill until deeply charred, 8–10 min per side.',
    'Ghee + cumin seeds 30 sec. Onion 12–15 min until deep gold.',
    'Garlic + ginger 2 min. Ground spices 1 min.',
    'Tomatoes 15 min uncovered until oil separates.',
    'Add chicken + cream. Simmer 8 min. Cilantro finish.'
  ],
  'Char is flavor — don''t skip the broil.',
  '',
  NULL
),

-- Shakshuka
(
  'shakshuka',
  'Shakshuka',
  'Middle Eastern',
  'Eggs',
  10,
  25,
  '2',
  'Easy',
  ARRAY['eggs', 'tomato', 'one-pan', 'breakfast'],
  '[
    {"title": "Ingredients", "items": [
      {"qty": "2 tbsp", "name": "olive oil"},
      {"qty": "1 large", "name": "onion, diced"},
      {"qty": "1", "name": "red bell pepper, diced"},
      {"qty": "4", "name": "garlic cloves, thinly sliced"},
      {"qty": "", "name": "2 tsp cumin, 1 tsp smoked paprika, ½ tsp caraway, pinch cayenne"},
      {"qty": "400g", "name": "crushed tomatoes"},
      {"qty": "1 tsp", "name": "sugar"},
      {"qty": "4–6 large", "name": "eggs"},
      {"qty": "100g", "name": "feta, crumbled"},
      {"qty": "", "name": "Parsley + crusty bread"}
    ]}
  ]'::jsonb,
  ARRAY[
    'Onion + pepper in oil, 8 min until soft.',
    'Garlic + spices 1–2 min.',
    'Tomatoes + sugar, simmer 10 min until thick.',
    'Make wells, crack eggs in.',
    'Cover 5–8 min until whites just set, yolks runny.',
    'Feta, parsley, olive oil. Serve from the pan.'
  ],
  'Pull when whites look barely set — residual heat finishes them.',
  '',
  NULL
)

ON CONFLICT (slug) DO NOTHING;
