CREATE SCHEMA project;

SET SEARCH_PATH = project;

-- 3
-- добавить регулярки + чекать даты

DROP TABLE IF EXISTS project.artists CASCADE;
CREATE TABLE project.artists
(
    artist_id      serial primary key,
    artist_name    varchar(100), -- can be null if unknown
    artist_surname varchar(100)  -- can be null if unknown
);

DROP TABLE IF EXISTS project.paintings CASCADE;
CREATE TABLE project.paintings
(
    painting_id            serial primary key,
    artist_id              integer,
    painting_name          varchar(100),
    painting_creation_year date check ( painting_creation_year <= current_date),

    foreign key (artist_id) references project.artists (artist_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.cities CASCADE;
CREATE TABLE project.cities
(
    city_id      serial primary key,
    city_name    varchar(100) not null,
    country_name varchar(100) not null
);

DROP TABLE IF EXISTS project.storages CASCADE;
CREATE TABLE project.storages
(
    storage_id       serial primary key,
    city_id          integer,
    storage_name     varchar(100) not null,
    storage_capacity integer check ( storage_capacity > 0 ),

    foreign key (city_id) references project.cities (city_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.owners CASCADE;
CREATE TABLE project.owners
(
    owner_id      serial primary key,
    owner_name    varchar(100) not null,
    owner_surname varchar(100) not null
);

DROP TYPE IF EXISTS deal_types CASCADE;
CREATE TYPE deal_types as ENUM ('sale', 'buy', 'create');

DROP TABLE IF EXISTS project.deals CASCADE;
CREATE TABLE project.deals
(
    deal_id     serial primary key,
    painting_id integer,
    owner_id    integer,
    deal_date   date,
    deal_price  integer check ( deal_price >= 0 ),
    deal_type   deal_types,

    foreign key (painting_id) references project.paintings (painting_id) on update cascade on delete restrict,
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.owner_x_deal CASCADE;
CREATE TABLE project.owner_x_deal
(
    deal_id  integer not null,
    owner_id integer not null,

    constraint pk_owner_x_deal primary key (deal_id, owner_id),
    foreign key (deal_id) references project.deals (deal_id) on update cascade on delete restrict,
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.ownership_history CASCADE;
CREATE TABLE project.ownership_history
(
    painting_id integer,
    valid_from  date,
    valid_until date,
    owner_id    integer,
    storage_id  integer,

    constraint pk_ownership_history primary key (painting_id, valid_from),
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete set null,
    foreign key (painting_id) references project.paintings (painting_id) on update cascade on delete cascade,
    foreign key (storage_id) references project.storages (storage_id) on update cascade on delete set null
);

-- 4

insert into project.artists(artist_name, artist_surname)
values ('Константин', 'Коровин'),
       ('Данте Габриэль', 'Россетти'),
       ('Иван', 'Куинджи'),
       ('Михаил', 'Врубель'),
       ('Исаак', 'Левитан');

insert into project.owners(owner_name, owner_surname)
values ('Сергей', 'Дымашевский'),
       ('Роман', 'Всемирнов'),
       ('Кристина', 'Трофимова'),
       ('Константин', 'Коровин'),
       ('Данте Габриэль', 'Россетти'),
       ('Иван', 'Куинджи'),
       ('Михаил', 'Врубель'),
       ('Исаак', 'Левитан');

insert into project.paintings(artist_id, painting_name, painting_creation_year)
values (1, 'Бульвар Капуцинок', '1906-01-01'),
       (2, 'Венера Вертикордия', '1864-01-01'),
       (2, 'Прозерпина', '1874-01-01'),
       (3, 'Солнечный свет в парке', '1908-01-01'),
       (4, 'Царевна-Лебедь', '1900-01-01'),
       (5, 'Вечер', '1877-01-01');

insert into project.cities(city_name, country_name)
values ('Красноярск', 'РФ'),
       ('Лондон', 'Великобритания'),
       ('Москва', 'РФ'),
       ('Цюрих', 'Швейцария'),
       ('Бремен', 'Германия'),
       ('Венеция', 'Италия');

insert into project.storages(city_id, storage_name, storage_capacity)
values (2, 'Лондонская национальная галерея', 2000),
       (3, 'Третьяковская галерея', 1000),
       (4, 'Кунстхаус', 20),
       (5, 'Бременская художественная галерея', 100),
       (3, 'Галерея современного искусства Гараж', 150),
       (6, 'Мастерская Россетти', NULL),
       (3, 'Мастерская Коровина', NULL),
       (3, 'Мастерская Куинджи', NULL),
       (3, 'Мастерская Врубеля', NULL),
       (3, 'Мастерская Левитана', NULL);

insert into project.deals(painting_id, deal_date, deal_price, deal_type, owner_id)
values (1, '1906-01-01', 0, 'create', 4),
       (2, '1864-01-01', 0, 'create', 5),
       (3, '1874-01-01', 0, 'create', 5),
       (4, '1908-01-01', 0, 'create', 6),
       (5, '1900-01-01', 0, 'create', 7),
       (6, '1877-01-01', 0, 'create', 8),
       (1, '1950-01-30', 5000, 'sale', 4),
       (1, '1950-01-30', 5000, 'buy', 1),
       (1, '2000-08-25', 500000, 'sale', 1),
       (1, '2000-08-25', 500000, 'buy', 2),
       (4, '1910-12-01', 300, 'sale', 6),
       (4, '1910-12-01', 300, 'buy', 2);

insert into project.owner_x_deal(deal_id, owner_id)
values (1, 4),
       (2, 5),
       (3, 5),
       (4, 6),
       (5, 7),
       (6, 8),
       (7, 4),
       (8, 1),
       (9, 8),
       (10, 2),
       (11, 6),
       (12, 2);

insert into project.ownership_history(owner_id, painting_id, valid_from, valid_until, storage_id)
values (4, 1, '1906-01-01', '1950-01-30', 7),
       (1, 1, '1950-01-30', '2000-08-25', 2),
       (2, 1, '2000-08-25', '3000-01-01', 4),
       (6, 4, '1908-01-01', '1910-12-01', 8),
       (2, 4, '1910-12-01', '3000-01-01', 4),
       (5, 2, '1864-01-01', '3000-01-01', 6),
       (5, 3, '1874-01-01', '3000-01-01', 6),
       (7, 5, '1900-01-01', '3000-01-01', 9),
       (8, 6, '1877-01-01', '3000-01-01', 10);

-- 5

select painting_name
from project.paintings
where artist_id = 3;

select sum(storage_capacity)
from project.storages;

delete
from project.owners
where owner_id = 3;

insert into project.owners(owner_name, owner_surname)
values ('Kristina', 'Trofimova');

delete
from project.owners
where owner_name = 'Kristina';

insert into project.paintings(artist_id, painting_name, painting_creation_year)
values (5, 'Вечир', '1877-01-01');

update project.paintings
set painting_name = 'Вечер'
where painting_id = 10;

update project.storages
set storage_name = 'Галерея современного творчества(альтушек) Гараж'
where storage_name = 'Галерея современного искусства Гараж';

-- 6

-- Вывести художников и их картины, упорядоченные сначала по художнику, а потом по картине

select project.artists.artist_surname || ' ' || project.artists.artist_name as artist,
       project.paintings.painting_name                                      as painting
from project.paintings
         inner join project.artists on project.artists.artist_id = project.paintings.artist_id
order by artist, painting;

-- Вывод: city: Москва, total_capacity: 1150
-- Вывести вместимость всех хранилищ по городам, находящимся в РФ, у которых вместимость ненулевая.
-- Красноярск не вывелся, потому что хранилищ там нет, значит, вместительность нулевая.

select city_name, sum(storage_capacity) as total_capacity
from project.storages
         left join project.cities on storages.city_id = cities.city_id
where country_name = 'РФ'
group by city_name
having sum(storage_capacity) > 0;

-- Все владельцы по убыванию продаж картин за всю историю

select owners.owner_name || ' ' || owners.owner_surname as owner, sum(deal_price) as total_sales
from project.owners
         left outer join project.deals on owners.owner_id = deals.owner_id
where deal_type = 'sale'
group by owner_name || ' ' || owners.owner_surname
order by total_sales desc;

-- Для каждой картины вывести всех владельцев с рангом(в порядке владения)

with extended_ownership_history as
         (select painting_name,
                 owner_name || ' ' || owners.owner_surname                          as owner,
                 valid_from,
                 valid_until,
                 dense_rank() over (partition by painting_name order by valid_from) as rank
          from project.ownership_history
                   left join project.owners on ownership_history.owner_id = owners.owner_id
                   left join project.paintings on paintings.painting_id = ownership_history.painting_id)
select rank, painting_name, owner
from extended_ownership_history;

-- Для каждой картины вывести

-- select owners.owner_name || ' ' || owners.owner_surname as owner, deal_price as total_sales from project.owners
-- left outer join project.deals on owners.owner_id = deals.owner_id;
--
-- with kek as (
--     select
-- )

-- select o_id, o_date, p_id, p_name, sum(p_price * s_q)
--     over (partition by p_id order by o_date rows between unbounded preceding and current row) from pd;

-- 7

CREATE SCHEMA project_views;

drop view if exists project_views.owners;
create view project_views.owners as
(
select owner_name, overlay(owner_surname placing '****' from 2)
from project.owners);

drop view if exists project_views.artists;
create view project_views.artists as
(
select artist_name as name, artist_surname as surname
from project.artists);

drop view if exists project_views.paintings;
create view project_views.paintings as
(
select artist_id, painting_name, painting_creation_year
from project.paintings);

drop view if exists project_views.cities;
create view project_views.cities as
(
select city_name as city, country_name as country
from project.cities);

drop view if exists project_views.storages;
create view project_views.storages as
(
select city_id, storage_name, storage_capacity
from project.storages);
DROP TABLE IF EXISTS project.artists CASCADE;
CREATE TABLE project.artists
(
    artist_id      serial primary key,
    artist_name    varchar(100), -- can be null if unknown
    artist_surname varchar(100)  -- can be null if unknown
);

DROP TABLE IF EXISTS project.paintings CASCADE;
CREATE TABLE project.paintings
(
    painting_id            serial primary key,
    artist_id              integer,
    painting_name          varchar(100),
    painting_creation_year date check ( painting_creation_year <= current_date),

    foreign key (artist_id) references project.artists (artist_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.cities CASCADE;
CREATE TABLE project.cities
(
    city_id      serial primary key,
    city_name    varchar(100) not null,
    country_name varchar(100) not null
);

DROP TABLE IF EXISTS project.storages CASCADE;
CREATE TABLE project.storages
(
    storage_id       serial primary key,
    city_id          integer,
    storage_name     varchar(100) not null,
    storage_capacity integer check ( storage_capacity > 0 ),

    foreign key (city_id) references project.cities (city_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.owners CASCADE;
CREATE TABLE project.owners
(
    owner_id      serial primary key,
    owner_name    varchar(100) not null,
    owner_surname varchar(100) not null
);

DROP TYPE IF EXISTS deal_types CASCADE;
CREATE TYPE deal_types as ENUM ('sale', 'buy', 'create');

DROP TABLE IF EXISTS project.deals CASCADE;
CREATE TABLE project.deals
(
    deal_id     serial primary key,
    painting_id integer,
    owner_id    integer,
    deal_date   date,
    deal_price  integer check ( deal_price >= 0 ),
    deal_type   deal_types,

    foreign key (painting_id) references project.paintings (painting_id) on update cascade on delete restrict,
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.owner_x_deal CASCADE;
CREATE TABLE project.owner_x_deal
(
    deal_id  integer not null,
    owner_id integer not null,

    constraint pk_owner_x_deal primary key (deal_id, owner_id),
    foreign key (deal_id) references project.deals (deal_id) on update cascade on delete restrict,
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete restrict
);

DROP TABLE IF EXISTS project.ownership_history CASCADE;
CREATE TABLE project.ownership_history
(
    painting_id integer,
    valid_from  date,
    valid_until date,
    owner_id    integer,
    storage_id  integer,

    constraint pk_ownership_history primary key (painting_id, valid_from),
    foreign key (owner_id) references project.owners (owner_id) on update cascade on delete set null,
    foreign key (painting_id) references project.paintings (painting_id) on update cascade on delete cascade,
    foreign key (storage_id) references project.storages (storage_id) on update cascade on delete set null
);

-- 4

insert into project.artists(artist_name, artist_surname)
values ('Константин', 'Коровин'),
       ('Данте Габриэль', 'Россетти'),
       ('Иван', 'Куинджи'),
       ('Михаил', 'Врубель'),
       ('Исаак', 'Левитан');

insert into project.owners(owner_name, owner_surname)
values ('Сергей', 'Дымашевский'),
       ('Роман', 'Всемирнов'),
       ('Кристина', 'Трофимова'),
       ('Константин', 'Коровин'),
       ('Данте Габриэль', 'Россетти'),
       ('Иван', 'Куинджи'),
       ('Михаил', 'Врубель'),
       ('Исаак', 'Левитан');

insert into project.paintings(artist_id, painting_name, painting_creation_year)
values (1, 'Бульвар Капуцинок', '1906-01-01'),
       (2, 'Венера Вертикордия', '1864-01-01'),
       (2, 'Прозерпина', '1874-01-01'),
       (3, 'Солнечный свет в парке', '1908-01-01'),
       (4, 'Царевна-Лебедь', '1900-01-01'),
       (5, 'Вечер', '1877-01-01');

insert into project.cities(city_name, country_name)
values ('Красноярск', 'РФ'),
       ('Лондон', 'Великобритания'),
       ('Москва', 'РФ'),
       ('Цюрих', 'Швейцария'),
       ('Бремен', 'Германия'),
       ('Венеция', 'Италия');

insert into project.storages(city_id, storage_name, storage_capacity)
values (2, 'Лондонская национальная галерея', 2000),
       (3, 'Третьяковская галерея', 1000),
       (4, 'Кунстхаус', 20),
       (5, 'Бременская художественная галерея', 100),
       (3, 'Галерея современного искусства Гараж', 150),
       (6, 'Мастерская Россетти', NULL),
       (3, 'Мастерская Коровина', NULL),
       (3, 'Мастерская Куинджи', NULL),
       (3, 'Мастерская Врубеля', NULL),
       (3, 'Мастерская Левитана', NULL);

insert into project.deals(painting_id, deal_date, deal_price, deal_type, owner_id)
values (1, '1906-01-01', 0, 'create', 4),
       (2, '1864-01-01', 0, 'create', 5),
       (3, '1874-01-01', 0, 'create', 5),
       (4, '1908-01-01', 0, 'create', 6),
       (5, '1900-01-01', 0, 'create', 7),
       (6, '1877-01-01', 0, 'create', 8),
       (1, '1950-01-30', 5000, 'sale', 4),
       (1, '1950-01-30', 5000, 'buy', 1),
       (1, '2000-08-25', 500000, 'sale', 1),
       (1, '2000-08-25', 500000, 'buy', 2),
       (4, '1910-12-01', 300, 'sale', 6),
       (4, '1910-12-01', 300, 'buy', 2);

insert into project.owner_x_deal(deal_id, owner_id)
values (1, 4),
       (2, 5),
       (3, 5),
       (4, 6),
       (5, 7),
       (6, 8),
       (7, 4),
       (8, 1),
       (9, 8),
       (10, 2),
       (11, 6),
       (12, 2);

insert into project.ownership_history(owner_id, painting_id, valid_from, valid_until, storage_id)
values (4, 1, '1906-01-01', '1950-01-30', 7),
       (1, 1, '1950-01-30', '2000-08-25', 2),
       (2, 1, '2000-08-25', '3000-01-01', 4),
       (6, 4, '1908-01-01', '1910-12-01', 8),
       (2, 4, '1910-12-01', '3000-01-01', 4),
       (5, 2, '1864-01-01', '3000-01-01', 6),
       (5, 3, '1874-01-01', '3000-01-01', 6),
       (7, 5, '1900-01-01', '3000-01-01', 9),
       (8, 6, '1877-01-01', '3000-01-01', 10);

-- 5

select painting_name
from project.paintings
where artist_id = 3;

select sum(storage_capacity)
from project.storages;

delete
from project.owners
where owner_id = 3;

insert into project.owners(owner_name, owner_surname)
values ('Kristina', 'Trofimova');

delete
from project.owners
where owner_name = 'Kristina';

insert into project.paintings(artist_id, painting_name, painting_creation_year)
values (5, 'Вечир', '1877-01-01');

update project.paintings
set painting_name = 'Вечер'
where painting_id = 10;

update project.storages
set storage_name = 'Галерея современного творчества(альтушек) Гараж'
where storage_name = 'Галерея современного искусства Гараж';

-- 6

-- Вывести художников и их картины, упорядоченные сначала по художнику, а потом по картине

select project.artists.artist_surname || ' ' || project.artists.artist_name as artist,
       project.paintings.painting_name                                      as painting
from project.paintings
         inner join project.artists on project.artists.artist_id = project.paintings.artist_id
order by artist, painting;

-- Вывод: city: Москва, total_capacity: 1150
-- Вывести вместимость всех хранилищ по городам, находящимся в РФ, у которых вместимость ненулевая.
-- Красноярск не вывелся, потому что хранилищ там нет, значит, вместительность нулевая.

select city_name, sum(storage_capacity) as total_capacity
from project.storages
         left join project.cities on storages.city_id = cities.city_id
where country_name = 'РФ'
group by city_name
having sum(storage_capacity) > 0;

-- Все владельцы по убыванию продаж картин за всю историю

select owners.owner_name || ' ' || owners.owner_surname as owner, sum(deal_price) as total_sales
from project.owners
         left outer join project.deals on owners.owner_id = deals.owner_id
where deal_type = 'sale'
group by owner_name || ' ' || owners.owner_surname
order by total_sales desc;

-- Для каждой картины вывести всех владельцев с рангом(в порядке владения)

with extended_ownership_history as
         (select painting_name,
                 owner_name || ' ' || owners.owner_surname                          as owner,
                 valid_from,
                 valid_until,
                 dense_rank() over (partition by painting_name order by valid_from) as rank
          from project.ownership_history
                   left join project.owners on ownership_history.owner_id = owners.owner_id
                   left join project.paintings on paintings.painting_id = ownership_history.painting_id)
select rank, painting_name, owner
from extended_ownership_history;

-- 7

CREATE SCHEMA project_views;

drop view if exists project_views.owners;
create view project_views.owners as
(
select owner_name, overlay(owner_surname placing '****' from 2) as owner_surname
from project.owners);

drop view if exists project_views.artists;
create view project_views.artists as
(
select artist_name as name, artist_surname as surname
from project.artists);

drop view if exists project_views.paintings;
create view project_views.paintings as
(
select artist_id, painting_name, painting_creation_year
from project.paintings);

drop view if exists project_views.cities;
create view project_views.cities as
(
select city_name as city, country_name as country
from project.cities);

drop view if exists project_views.storages;
create view project_views.storages as
(
select city_id, storage_name, storage_capacity
from project.storages);

drop view if exists project_views.deals;
create view project_views.deals as
(
select deal_id,
       deal_type,
       overlay(cast(deal_price as varchar) placing '**' from 1) as deal_price,
       deal_date,
       owner_id                                                 as price
from project.deals);

drop view if exists project_views.ownership_history;
create view project_views.ownership_history as
(
select painting_id,
       valid_from,
       valid_until,
       overlay(cast(owner_id as varchar) placing '**' from 1)   as owner_id,
       overlay(cast(storage_id as varchar) placing '**' from 1) as storage_id
from project.ownership_history);

-- 8

-- Расширенная человекочитаемая информация о всех сделках.
-- Колонки: картина, актор сделки, тип сделки, цена, дата сделки.

drop view if exists project_views.deals_history;
create view project_views.deals_history as
(
select painting_name, owner_name || ' ' || owners.owner_surname as owner, deal_type, deal_price, deal_date
from project.deals
         inner join project.paintings on deals.painting_id = paintings.painting_id
         inner join project.owners on deals.owner_id = owners.owner_id
    );

-- Расширенная информация о картинах и их истории владения.
-- Колонки: картина, дата создания, художник, владелец, место хранения, город хранения, сроки владения

drop view if exists project_views.paintings_info;
create view project_views.painting_info as
(
select painting_name,
       painting_creation_year,
       artist_name || ' ' || artists.artist_surname as artist,
       owner_name || ' ' || owners.owner_surname    as owner,
       storage_name,
       city_name,
       valid_from,
       valid_until
from project.paintings
         inner join project.artists on artists.artist_id = paintings.artist_id
         inner join project.ownership_history on paintings.painting_id = ownership_history.painting_id
         inner join project.owners on ownership_history.owner_id = owners.owner_id
         inner join project.storages on ownership_history.storage_id = storages.storage_id
         inner join project.cities on storages.city_id = cities.city_id
order by painting_name, artist, valid_from
    );

-- Расширенная информация о владельцах
-- Колонки: имя владельца



