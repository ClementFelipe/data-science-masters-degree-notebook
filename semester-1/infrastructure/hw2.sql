drop schema if exists olap_sakila;
drop table if exists olap_sakila.h_rental cascade;
drop table if exists olap_sakila.dim_time cascade;
drop table if exists olap_sakila.dim_film cascade;

create schema olap_sakila;

create table if not exists olap_sakila.dim_time (
    id_date int auto_increment,
    date_original date,
    date_day int not null,
    date_month int not null,
    date_year int not null,
    date_quarter int not null,
    primary key (id_date)
);

create table if not exists olap_sakila.dim_film (
	id_film int auto_increment,
    title varchar(255),
    category varchar(25),
    primary key (id_film)
);

create table if not exists olap_sakila.h_rental (
	id_rental int auto_increment,
    id_date int,
    id_film int,
    cantidad_alquilada int,
    primary key (id_rental),
    foreign key (id_date)
    references olap_sakila.dim_time(id_date),
    foreign key (id_film)
    references olap_sakila.dim_film(id_film)
);

insert into olap_sakila.dim_time (date_original, date_day, date_month, date_year, date_quarter)
select
  distinct date(rental_date),
  day(rental_date),
  month(rental_date),
  year(rental_date),
  quarter(rental_date)
from sakila.rental;

insert into olap_sakila.dim_film (id_film, title, category)
select
  r.film_id,
  r.title,
  ca.name
from (
	select 
      f.film_id,
      f.title title,
      min(c.category_id) category_id
	from sakila.film f 
	inner join sakila.film_category fc on f.film_id = fc.film_id
	inner join sakila.category c on fc.category_id = c.category_id
	group by f.film_id, title
) r
inner join sakila.category ca on r.category_id = ca.category_id;       

insert into olap_sakila.h_rental (id_date,id_film,cantidad_alquilada)
select 
  d.id_date,
  f.film_id,
  count(1)
from sakila.rental r 
inner join sakila.inventory i on r.inventory_id = i.inventory_id
inner join sakila.film f on f.film_id = i.film_id
inner join olap_sakila.dim_film fo on fo.title = f.title 
inner join olap_sakila.dim_time d on d.date_original = date(r.rental_date)
group by d.id_date, f.film_id;    

select t.date_original, f.title, f.category, r.cantidad_alquilada 
	from olap_sakila.h_rental r 
	inner join olap_sakila.dim_time t on r.id_date = t.id_date
    inner join olap_sakila.dim_film f on r.id_film = f.id_film
    where t.date_year = 2005 and t.date_quarter = 2
    order by r.cantidad_alquilada desc;

