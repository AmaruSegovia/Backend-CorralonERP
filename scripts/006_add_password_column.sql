-- Migration: Add password column to users table
-- Run this script to update your existing MySQL database

ALTER TABLE users ADD COLUMN password VARCHAR(255) NOT NULL DEFAULT '' AFTER email;

-- Note: After running this, you can register new users through the NestJS API
-- Existing users (if any) will need their passwords set manually or through a reset flow
