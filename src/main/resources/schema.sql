-- BookTrail Database Schema & Seed Data

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(64) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    total_chapters INT NOT NULL,
    synopsis TEXT,
    cover_url VARCHAR(255),
    published_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_bookshelf (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    status VARCHAR(30) NOT NULL,
    chapters_read INT NOT NULL DEFAULT 0,
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shelf_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_shelf_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_book UNIQUE (user_id, book_id)
);

CREATE TABLE IF NOT EXISTS discussion_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    chapter_start INT NOT NULL,
    chapter_end INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    title VARCHAR(250) NOT NULL,
    content TEXT NOT NULL,
    has_spoilers BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_post_room FOREIGN KEY (room_id) REFERENCES discussion_rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_post_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_review UNIQUE (user_id, book_id)
);

-- Seed Books (using standard SQL double single-quote '' for escaping)
INSERT INTO books (id, title, author, genre, total_chapters, synopsis, cover_url, published_year) VALUES
(1, 'Dune', 'Frank Herbert', 'Science Fiction', 48, 'Set on the desert planet Arrakis, Dune tells the story of Paul Atreides as he navigates political betrayal, mysterious prophecy, and giant sandworms in a battle for control of the universe''s most precious resource.', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80', 1965),
(2, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 19, 'Bilbo Baggins, a peaceful hobbit living in the Shire, is whisked away into an epic quest by the wizard Gandalf and thirteen dwarves to reclaim the Lonely Mountain from the dragon Smaug.', 'https://images.unsplash.com/photo-1629992101753-56d196c8aabb?w=400&auto=format&fit=crop&q=80', 1937),
(3, 'Pride and Prejudice', 'Jane Austen', 'Classic Literature', 61, 'A timeless romantic comedy focusing on the turbulent relationship between Elizabeth Bennet, the daughter of a country gentleman, and Fitzwilliam Darcy, a rich aristocratic landowner.', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&auto=format&fit=crop&q=80', 1813),
(4, 'Project Hail Mary', 'Andy Weir', 'Science Fiction', 30, 'Ryland Grace is the sole survivor on a desperate, last-chance mission—and if he fails, humanity and the earth itself will perish. Except right now, he doesn''t even remember his own name.', 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&auto=format&fit=crop&q=80', 2021),
(5, 'Klara and the Sun', 'Kazuo Ishiguro', 'Literary Fiction', 25, 'Told from the perspective of Klara, an Artificial Friend with outstanding observational qualities, who watches the behavior of those who come in to browse, and of those who pass in the street outside.', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&auto=format&fit=crop&q=80', 2021),
(6, '1984', 'George Orwell', 'Dystopian', 24, 'Winston Smith struggles against the totalitarian regime of the Party and its omnipresent leader, Big Brother, in a harrowing vision of truth, surveillance, and personal autonomy.', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&auto=format&fit=crop&q=80', 1949);

-- Seed Discussion Rooms
INSERT INTO discussion_rooms (id, book_id, title, chapter_start, chapter_end, description) VALUES
(1, 1, 'Arrival on Arrakis (Chapters 1 - 10)', 1, 10, 'Discussion for Paul''s arrival on the desert planet, the Gom Jabbar test, and the first hints of the Bene Gesserit prophecy.'),
(2, 1, 'The Fall of House Atreides (Chapters 11 - 22)', 11, 22, 'SPOILER ZONE: The betrayal of Doctor Yueh, the Harkonnen assault, and the Duke''s final confrontation.'),
(3, 1, 'Among the Fremen (Chapters 23 - 35)', 23, 35, 'Paul and Jessica''s survival in the deep desert, riding the maker, and learning the Fremen ways.'),
(4, 1, 'The Prophecy Fulfilled (Chapters 36 - 48)', 36, 48, 'The battle of Arrakeen, the Emperor''s descent, and Paul''s ascent as Muad''Dib.'),
(5, 2, 'An Unexpected Party & The Journey (Chapters 1 - 7)', 1, 7, 'Bag End tea time, encounters with trolls, Elrond in Rivendell, and escaping the Misty Mountains.'),
(6, 2, 'Riddles in the Dark & Mirkwood (Chapters 8 - 12)', 8, 12, 'Gollum''s riddles, finding the precious Ring, giant spiders, and wood-elf barrels.'),
(7, 2, 'The Dragon''s Lair & Five Armies (Chapters 13 - 19)', 13, 19, 'Entering the Lonely Mountain, Smaug''s fury over Lake-town, and the climactic clash of armies.'),
(8, 4, 'Waking Up in Solitary (Chapters 1 - 8)', 1, 8, 'Amnesia in zero gravity, diagnosing the Astrophage crisis, and realizing what Hail Mary truly is.'),
(9, 4, 'First Contact: Meet Rocky (Chapters 9 - 18)', 9, 18, 'Meeting the Blip-A, discovering Eridian biology, creating a translation language, and building trust.'),
(10, 4, 'Taumoeba & The Final Sacrifice (Chapters 19 - 30)', 19, 30, 'Breeding super-predators, saving Rocky from doomed fuel leaks, and an unexpected homecoming.');

-- Seed Users
-- Password for all is "password123", salt is "salt123"
INSERT INTO users (id, username, email, password_hash, salt, role, bio) VALUES
(1, 'elena_reader', 'elena@booktrail.org', 'c465f66c6ac481a7a17e9ed5b4e2e7e7288d892f12bf1c95c140901e9a70436e', 'salt123', 'USER', 'Avid sci-fi reader, tea drinker, and slow-paced literature enthusiast.'),
(2, 'marcus_atredies', 'marcus@booktrail.org', 'c465f66c6ac481a7a17e9ed5b4e2e7e7288d892f12bf1c95c140901e9a70436e', 'salt123', 'USER', 'Re-reading Frank Herbert for the fifth time. Discussing worldbuilding & lore.'),
(3, 'admin', 'admin@booktrail.org', 'c465f66c6ac481a7a17e9ed5b4e2e7e7288d892f12bf1c95c140901e9a70436e', 'salt123', 'ADMIN', 'BookTrail Community Caretaker and System Administrator.');

-- Seed User Bookshelf
INSERT INTO user_bookshelf (user_id, book_id, status, chapters_read, notes) VALUES
(1, 1, 'CURRENTLY_READING', 10, 'Loving the ecological worldbuilding so far! Water discipline is fascinating.'),
(1, 2, 'COMPLETED', 19, 'A comfort read that never gets old. Smaug was terrifying as always.'),
(1, 4, 'WANT_TO_READ', 0, 'Recommended by three friends, starting next weekend.'),
(2, 1, 'COMPLETED', 48, 'A masterpiece of political intrigue and ecological destiny.');

-- Seed Discussion Posts
INSERT INTO posts (id, room_id, user_id, title, content, has_spoilers) VALUES
(1, 1, 1, 'The Gom Jabbar scene set the tone immediately', 'The tension in the first chapter with Reverend Mother Mohiam was masterfully written. The idea of human will overcoming instinct through the pain box was chilling.', FALSE),
(2, 1, 2, 'Frank Herbert''s ecology notes in early chapters', 'Notice how many times water is mentioned before they even land on Arrakis? The psychological preparation makes the planet feel thirsty before we see it.', FALSE),
(3, 2, 2, 'Yueh''s Suk conditioning tragedy', 'How the Harkonnens broke an unbreakable imperial doctor conditioning using his wife Wanna is heartbreaking. His small revenge with the false tooth was pure genius.', TRUE),
(4, 5, 1, 'Riddles in the dark is peak fantasy dialogue', 'The linguistic play in the riddle game between Bilbo and Gollum holds up so well. "What have I got in my pocket?" is iconic.', FALSE),
(5, 9, 2, 'Amaze! Amaze! Amaze!', 'Rocky is hands down one of the most endearing sci-fi companions ever written. The xenobiology of the Eridians feels both utterly alien and deeply lovable.', FALSE);

-- Seed Comments
INSERT INTO comments (id, post_id, user_id, content) VALUES
(1, 1, 2, 'Agreed! And it establishes right away that Paul isn''t an ordinary noble heir.'),
(2, 1, 1, 'Exactly! Can''t wait to see how the Bene Gesserit plans unravel as I read further.'),
(3, 4, 2, 'Tolkien actually revised that chapter in later editions after writing LOTR to make the Ring more sinister!'),
(4, 5, 1, 'Fist bump! Question: you sleep, I watch? That friendship literally made me cry happy tears.');

-- Seed Reviews
INSERT INTO reviews (id, book_id, user_id, rating, review_text) VALUES
(1, 2, 1, 5, 'The Hobbit is a masterpiece of adventure and warmth. Bilbo''s transformation from timid homebody to brave hero is executed with charm, wit, and unforgettable poetry.'),
(2, 1, 2, 5, 'Dune is monumental. The blend of resource politics, religious manipulation, and high-stakes survival has defined science fiction for generations.');
