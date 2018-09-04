PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255),
  lname VARCHAR(255)
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(150),
  body TEXT,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER,
  body TEXT,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ('Jonathan', 'Chu'), 
  ('Cassandra', 'McClure'), 
  ('User', '3');

INSERT INTO 
  questions (title, body, author_id)
VALUES 
  ('webshot.rb', 'How do I shot web in ruby2.5?', 2), 
  ('App Academy Survival', 'How do I make it out alive?', 1), 
  ('USER WAS BANNED', '[CONTENT REMOVED]', 3),
  ('Cool New Vid', 'Found this cool new vid, [link here]. Discuss', 2);
  
INSERT INTO
  question_follows(question_id, user_id)
VALUES 
  (1, 3),
  (2, 3),
  (3, 3),
  (4, 3),
  (2, 2),
  (2, 1),
  (4, 1);
  
INSERT INTO 
  replies (question_id, reply_id, user_id, body)
VALUES 
  (3, NULL, 2, 'USER 3, PLEASE STOP'),
  (3, 1, 1, 'C''mon USER 3, you''re better than that!'),
  (4, NULL, 1, 'very hilariously funny video!');
  
INSERT INTO 
  question_likes (question_id, user_id)
VALUES
  (4, 1),
  (1, 1),
  (3, 2),
  (2, 2),
  (1, 3),
  (2, 3),
  (3, 3),
  (4, 3),
  (4, 2);
