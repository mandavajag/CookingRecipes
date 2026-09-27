-- Kitchen App - Admin User Seed
-- Run: wrangler d1 execute cooking_recipes --file=./migrations/0003_seed_admin.sql
-- 
-- Admin credentials:
--   Email: mandavajag@gmail.com
--   Password: welcome1234 (PBKDF2-SHA256 hashed)

INSERT INTO users (email, password_hash)
VALUES ('mandavajag@gmail.com', 'pbkdf2-sha256$100000$hnYJM0/PHtJ9nwWcRiQPsQ==$KElrR4pMMCwuLPFMkRNhqyEyNkkHyjqolzFXnSNtMD8=');
