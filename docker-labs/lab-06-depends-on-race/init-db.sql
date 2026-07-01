-- Init script that makes DB startup take longer (simulating real-world)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0
);

-- Insert some seed data
INSERT INTO users (username, email) VALUES ('admin', 'admin@example.com');
INSERT INTO products (name, price, stock) VALUES 
    ('Widget A', 9.99, 100),
    ('Widget B', 19.99, 50),
    ('Widget C', 29.99, 25);

-- Simulate heavy initialization
DO $$
BEGIN
    PERFORM pg_sleep(3);
END $$;
