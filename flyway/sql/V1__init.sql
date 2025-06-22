-- Sample Script for creating the database schema.
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR NOT NULL,
    date_of_birth DATE NOT NULL CHECK (date_of_birth < CURRENT_DATE)
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
