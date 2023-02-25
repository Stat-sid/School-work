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


CREATE TABLE Artists (
  name TEXT PRIMARY KEY );
  
CREATE TABLE Songs (
  title TEXT,
  length INT NOT NULL,
  artistName TEXT,
  PRIMARY KEY (title, artistName),
  FOREIGN KEY (artistName) REFERENCES Artists(name) );
 
CREATE TABLE Playlists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  owner TEXT NOT NULL );
  
CREATE TABLE PlaylistSongs (
  playlist TEXT NOT NULL REFERENCES Playlists (id),
  song TEXT,
  artist TEXT,
  position INT NOT NULL,
  FOREIGN KEY (song, artist) REFERENCES Songs (title, artistName),
  PRIMARY KEY (playlist, position) );


-- Some values
INSERT INTO Artists VALUES ('ABBA');
INSERT INTO Artists VALUES ('Pink Floyd');
INSERT INTO Artists VALUES ('Roxette');
INSERT INTO Artists VALUES ('John Lundvik');
INSERT INTO Songs VALUES ('Dancing Queen', 4, 'ABBA');
INSERT INTO Songs VALUES ('It must have been love', 3, 'Roxette');
INSERT INTO Songs VALUES ('Too late for love', 5, 'John Lundvik');
INSERT INTO Songs VALUES ('Animals', 4, 'Pink Floyd');
INSERT INTO Playlists VALUES ('M123', 'My Favourites', 'Ana');
INSERT INTO Playlists VALUES ('XX', 'Other', 'Ana');
INSERT INTO PlaylistSongs VALUES ('M123', 'Dancing Queen', 'ABBA', 1);
INSERT INTO PlaylistSongs VALUES ('M123', 'Too late for love', 'John Lundvik', 2);
INSERT INTO PlaylistSongs VALUES ('XX','It must have been love', 'Roxette', 1);
