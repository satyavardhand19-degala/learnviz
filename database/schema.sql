-- Learnvis Database Schema

CREATE TABLE modules (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255)
);

CREATE TABLE experiments (
    id SERIAL PRIMARY KEY,
    module_id INT REFERENCES modules(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    formula_template TEXT,
    initial_params_json TEXT,
    difficulty_level VARCHAR(50) DEFAULT 'Beginner'
);

CREATE TABLE formulas (
    id SERIAL PRIMARY KEY,
    experiment_id INT REFERENCES experiments(id),
    name VARCHAR(255),
    latex_string TEXT,
    explanation TEXT
);

CREATE TABLE quizzes (
    id SERIAL PRIMARY KEY,
    experiment_id INT REFERENCES experiments(id),
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_option INT NOT NULL
);
