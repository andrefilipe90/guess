mkdir number_guessing_game
cd number_guessing_game
touch number_guess.sh
chmod +x number_guess.sh
echo '#!/bin/bash' >  number_guess.sh
git init
git checkout -b main
psql -U freecodecamp -d prostgres
CREATE DATABASE number_guess;
\c number_guess
CREATE TABLE users(user_id SERIAL PRIMARY KEY, name varchar(22) NOT NULL UNIQUE);
CREATE TABLE numbers(number_id SERIAL PRIMARY KEY, user_id INT NOT NULL, random INT DEFAULT floor(random() * 1001), last_try INT, total_try INT, total_games INT, best_game INT);
ALTER TABLE numbers ADD FOREIGN KEY (user_id) REFERENCES users(user_id);
