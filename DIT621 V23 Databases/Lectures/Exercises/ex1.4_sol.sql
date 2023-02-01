-- psql -v ON_ERROR_STOP=1 -U postgres portal

-- Deletes everything to make this file re-runnable
\set QUIET true
SET client_min_messages TO NOTICE;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false


-- a) Tables
-- Tenants (_personal_nr_, name, tel)
CREATE TABLE Tenants (
  personal_nr INT CHECK (personal_nr > 0) PRIMARY KEY, 
  name TEXT NOT NULL,
  tel INT NOT NULL CHECK (tel > 0) );

-- Building (_tenant_, _apt_nr_)
--  tenant → Tenants.personal_nr
CREATE TABLE Building (
  tenant INT NOT NULL REFERENCES Tenants,
  apt_nr INT CHECK (apt_nr > 0 AND apt_nr <= 100),
  PRIMARY KEY (tenant, apt_nr) );

-- BookingPrices (_facility_, price)
CREATE TABLE BookingPrices (
  facility TEXT PRIMARY KEY
  CHECK (facility in ('sauna', 'wash1', 'wash2', 'party')),
  price INT NOT NULL CHECK (price > 0) );

-- Bookings (_facility_, _day_, _time_, apt nr)
--  facility → BookingPrices.facility
CREATE TABLE Bookings (
  facility TEXT NOT NULL REFERENCES BookingPrices,
  day DATE NOT NULL,
  time INT NOT NULL CHECK (time in (8, 11, 14, 17, 20)),
  apt_nr INT NOT NULL CHECK (apt_nr > 0 AND apt_nr <= 100),
  CHECK (facility != 'party' OR time = 8),
  PRIMARY KEY (facility, day, time),
  UNIQUE (facility, day, apt_nr) );


-- b) 
CREATE TABLE Banned (
  personal_nr INT REFERENCES Tenants, 
  facility TEXT REFERENCES BookingPrices,
  day DATE NOT NULL,
  PRIMARY KEY (personal_nr, facility, day) );


-- Test data
INSERT INTO Tenants VALUES (2020, 'Aggie', 20);
INSERT INTO Tenants VALUES (2018, 'Castor', 18);
INSERT INTO Tenants VALUES (2000, 'Sickan', 24);
INSERT INTO Tenants VALUES (2016, 'Florida', 8);
INSERT INTO Tenants VALUES (2013, 'Ferrero', 22);
INSERT INTO Tenants VALUES (2017, 'Nelson', 9);

INSERT INTO Building VALUES (2020, 1);
INSERT INTO Building VALUES (2018, 1);
INSERT INTO Building VALUES (2020, 2);
INSERT INTO Building VALUES (2000, 3);
INSERT INTO Building VALUES (2016, 4);
INSERT INTO Building VALUES (2013, 5);
INSERT INTO Building VALUES (2017, 5);

INSERT INTO BookingPrices VALUES ('sauna', 100);
INSERT INTO BookingPrices VALUES ('wash1', 50);
INSERT INTO BookingPrices VALUES ('wash2', 50);
INSERT INTO BookingPrices VALUES ('party', 200);

INSERT INTO Bookings VALUES ('sauna', CURRENT_DATE, 11, 5);
INSERT INTO Bookings VALUES ('party', CURRENT_DATE, 8, 1);
INSERT INTO Bookings VALUES ('party', '2023-08-20', 8, 1);
INSERT INTO Bookings VALUES ('wash1', '2023-08-22', 11, 2);
INSERT INTO Bookings VALUES ('wash2', '2023-08-22', 20, 2);
INSERT INTO Bookings VALUES ('sauna', CURRENT_DATE+1, 11, 4);
INSERT INTO Bookings VALUES ('party', '2023-08-24', 8, 4);
INSERT INTO Bookings VALUES ('wash1', '2023-08-24', 11, 3);
INSERT INTO Bookings VALUES ('wash2', '2023-08-25', 20, 5);
INSERT INTO Bookings VALUES ('sauna', CURRENT_DATE, 14, 2);
INSERT INTO Bookings VALUES ('wash2', '2023-09-25', 20, 5);

INSERT INTO Banned VALUES (2020, 'sauna', '2023-07-20');
INSERT INTO Banned VALUES (2020, 'party', '2023-07-20');
INSERT INTO Banned VALUES (2017, 'wash1', CURRENT_DATE-10);
INSERT INTO Banned VALUES (2017, 'wash2', CURRENT_DATE-1);


-- c) top bookings
WITH MostBookings AS
  (SELECT apt_nr, facility, COUNT(*) AS total
   FROM Bookings
   WHERE date_part('year', CURRENT_DATE) = date_part('year', day)
   GROUP BY facility, apt_nr
   ORDER BY total DESC
   LIMIT 10)
SELECT apt_nr, name, facility, total
FROM (MostBookings JOIN Building USING (apt_nr))
     JOIN Tenants ON tenant = personal_nr
ORDER BY total DESC, apt_nr, facility;


-- d) tenants with bookings today
SELECT apt_nr, name, facility, time
FROM Tenants, (Building NATURAL JOIN Bookings)
WHERE day = CURRENT_DATE AND tenant = personal_nr
ORDER BY facility, time;


-- e) % per tenant in apartment
CREATE OR REPLACE VIEW Percentages AS
SELECT apt_nr, ROUND(100/COUNT(*)) AS perc
FROM Building
GROUP BY apt_nr
ORDER BY perc DESC, apt_nr;

SELECT * FROM Percentages;


-- f) monthly bill
CREATE OR REPLACE VIEW MonthlyBill AS
WITH
BillPerApt AS
(SELECT apt_nr, SUM(PRICE)
FROM Bookings JOIN BookingPrices USING (facility)
WHERE date_part('year', CURRENT_DATE) = date_part('year', day) AND
      date_part('month', CURRENT_DATE) = date_part('month', day)
GROUP BY apt_nr),
BillPerTenant AS
(SELECT tenant, ROUND(sum * perc/100) AS apt_fee
FROM (BillPerApt JOIN Building USING (apt_nr)) JOIN Percentages USING (apt_nr))
SELECT tenant, SUM(apt_fee) AS fee
FROM BillPerTenant
GROUP BY tenant
ORDER BY tenant;

SELECT * FROM MonthlyBill;
