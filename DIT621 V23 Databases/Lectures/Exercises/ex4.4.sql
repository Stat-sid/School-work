/*
psql -v ON_ERROR_STOP=1 -U postgres portal
*/

-- Deletes everything
\c portal
\set QUIT true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- Users’ basic information
CREATE TABLE Users (
  login TEXT PRIMARY KEY,          
  email TEXT NOT NULL,
  UNIQUE (email)); 

-- Premium users are an specialization of users
CREATE TABLE PremiumUsers (
  usr TEXT NOT NULL REFERENCES Users,
  expiration_date DATE NOT NULL,
  PRIMARY KEY (usr));

-- Movies’ basic information
CREATE TABLE Movies (
  title TEXT NOT NULL,
  year INTEGER NOT NULL,
  genre TEXT NOT NULL,
  PRIMARY KEY (title, year), 
  CHECK (genre IN ('Action', 'Sci-fi', 'Comedy', 'Drama'))); 

-- All users can rate a movie
CREATE TABLE Ratings (
  usr TEXT NOT NULL REFERENCES Users,
  title TEXT NOT NULL,
  year INTEGER NOT NULL,
  rate INTEGER NOT NULL,
  PRIMARY KEY (usr, title, year),
  FOREIGN KEY (title, year) REFERENCES Movies,
  CHECK (rate IN (1,2,3,4,5)));                  -- Point system

-- Only premium users are allowed to comment
CREATE TABLE Comments (
  usr CHAR(5) NOT NULL REFERENCES PremiumUsers, 
  title TEXT NOT NULL,
  year INTEGER NOT NULL,
  comment TEXT NOT NULL,
  PRIMARY KEY (usr, title, year),
  FOREIGN KEY (title, year) REFERENCES Movies);

-- Movies with score above 4.0
CREATE TABLE CertifiedCrisp (
  title TEXT NOT NULL,
  year INTEGER NOT NULL,
  PRIMARY KEY (title, year),
  FOREIGN KEY (title, year) REFERENCES Movies);


-- scores are computed as the average of the rates
CREATE VIEW MoviesScores AS
SELECT title AS movie, year, COALESCE (AVG(rate),0) AS score
FROM Movies NATURAL JOIN Ratings
GROUP BY (title , year);

CREATE VIEW Reviews AS
SELECT usr, title AS movie, year, rate, comment
FROM MOVIES NATURAL LEFT JOIN Ratings NATURAL LEFT JOIN Comments;


-- Inserting a review can affect CertifiedCrisp
CREATE FUNCTION insertReview () RETURNS TRIGGER AS $$
DECLARE newScore FLOAT;
BEGIN
  INSERT INTO Ratings VALUES (NEW.usr, NEW.movie, NEW.year, NEW.rate);
  IF (EXISTS (SELECT usr FROM PremiumUsers WHERE usr = NEW.usr)
      AND NEW.comment IS NOT NULL)
  THEN INSERT INTO Comments
       VALUES (NEW.usr, NEW.movie, NEW.year, NEW.comment);
  END IF;
  newScore := (SELECT score FROM MoviesScores
               WHERE (movie, year) = (NEW.movie, NEW.year));
  IF (NOT EXISTS (SELECT * FROM CertifiedCrisp
                  WHERE (title, year) = (NEW.movie, NEW.year))
      AND (newScore > 4))
  THEN INSERT INTO CertifiedCrisp VALUES (NEW.movie, NEW.year);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER InsertReviewTrigger
INSTEAD OF INSERT ON Reviews
FOR EACH ROW
EXECUTE PROCEDURE insertReview ();


-- Deleting a review can affect CertifiedCrisp
CREATE FUNCTION deleteReview () RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM Ratings
  WHERE usr = OLD.usr AND title = OLD.movie AND year = OLD.year;
  IF (EXISTS (SELECT usr FROM PremiumUsers WHERE usr = OLD.usr))
  THEN DELETE FROM Comments
       WHERE usr = OLD.usr AND title = OLD.movie AND year = OLD.year;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER DeleteReviewTrigger
INSTEAD OF DELETE ON Reviews
FOR EACH ROW
EXECUTE PROCEDURE deleteReview ();
