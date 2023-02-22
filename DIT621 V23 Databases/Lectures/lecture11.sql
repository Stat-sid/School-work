DROP TABLE IF EXISTS Menus;

CREATE TABLE Menus (
  id serial not null,
  menu jsonb not null
  );

insert into Menus (menu) values (
'[{"category":"Starters",
  "contents":[
    {"dish":"Calamari", "price":8.50}]},
 {"category":"Salads",
  "contents":[
    {"dish":"Caesar",  "price":8.50},
    {"dish":"Chicken", "price":9.25}]},
 {"category":"Burgers",
  "contents":[
    {"dish":"Standard", "price":9},
    {"dish":"Bacon",    "price":10},
    {"category":"Vegetarian Burgers",
     "contents":[
       {"dish":"Haloumi",  "price":13},
       {"dish":"Mushroom", "price":10}]}]}]' ::JSONB
);

insert into Menus (menu) values (
'[{"category":"Soups",
  "contents":[
    {"dish":"Lentil", "dish": "Chicken", "price":20.50}]}
 ]' ::JSONB

);

select * from menus;

SELECT SUM(query.value)
from (
SELECT (jsonb_path_query(menu,
 'strict $.**.price'
 )  :: int) as value from menus) as query;

-- We can also feed in the JSON data directly,
-- if we e.g. just want to play around with
-- queries
WITH JsonEx as (SELECT '
[{"category":"Starters",
  "contents":[
    {"dish":"Calamari", "price":8.50}]},
 {"category":"Salads",
  "contents":[
    {"dish":"Caesar",  "price":8.50},
    {"dish":"Chicken", "price":9.25}]},
 {"category":"Burgers",
  "contents":[
    {"dish":"Standard", "price":9},
    {"dish":"Bacon",    "price":10},
    {"category":"Vegetarian Burgers",
     "contents":[
       {"dish":"Haloumi",  "price":13},
       {"dish":"Mushroom", "price":10}]}]}]
 '::JSONB as val)
Select SUM(res.value :: int)
from (
SELECT jsonb_path_query(val,
 'strict $[*]?(@.category == "Burgers").**.price'
 ) as value FROM JsonEx) as res;
