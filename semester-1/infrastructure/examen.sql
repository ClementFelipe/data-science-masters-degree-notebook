-- 1. Cuales fueron las tiendas donde se registraron los mayores montos pagados a las rentas entre el año 2005 y 2006
drop schema if exists olap_felipe;

create schema olap_felipe;

create table olap_felipe.dim_time (
  id int primary key auto_increment,
  date date not null,
  year int not null,
  month int not null,
  day int not null
);

create table olap_felipe.dim_store (
  id int primary key,
  address varchar(50) not null
);

create table olap_felipe.h_payment (
  payment_id int primary key auto_increment,
  dim_time_id int not null,
  dim_store_id int not null,
  amount decimal(7, 2) not null,
  foreign key fk_dim_time_id(dim_time_id) references olap_felipe.dim_time(id),
  foreign key fk_dim_store_id(dim_store_id) references olap_felipe.dim_store(id)
);

insert into olap_felipe.dim_time (date, year, month, day)
select
  distinct date(payment_date) as date,
  year(payment_date) as year,
  month(payment_date) as month,
  day(payment_date) as day
from sakila.payment
order by date;

insert into olap_felipe.dim_store (id, address)
select
  st.store_id as id,
  ad.address as adress
from sakila.store as st
inner join sakila.address as ad on st.address_id = ad.address_id;

insert into olap_felipe.h_payment (dim_time_id, dim_store_id, amount)
select
  dt.id as dim_time_id,
  ds.id as dim_store_id,
  sum(pa.amount)
from sakila.payment as pa
inner join olap_felipe.dim_time as dt on date(pa.payment_date) = dt.date
inner join sakila.rental as re on pa.rental_id = re.rental_id
inner join sakila.customer as cu on re.customer_id = cu.customer_id
inner join olap_felipe.dim_store as ds on cu.store_id = ds.id
group by dt.id, ds.id;

-- EJEMPLO:

select
  sum(hp.amount) as amount,
  ds.address as address,
  dt.year as year
from olap_felipe.h_payment as hp
inner join olap_felipe.dim_time as dt on hp.dim_time_id = dt.id
inner join olap_felipe.dim_store as ds on hp.dim_store_id = ds.id
where dt.year >= 2005 and dt.year <= 2006
group by ds.id, dt.year
order by amount desc;

-- 2. Cual es la diferencia entre crear un diseño olap multidimensional y trabajar directamente con datasets (archivos de datos).

-- La diferencia que existe entre trabajar con un diseño multidimensional y directamente con datasets
-- radica en lo "listos" que se encuentran los datos para la toma de decisiones. El termino multidimensional se aplica a 
-- modelos que contienen datos extraídos de un conjunto de datos más grande que ha sido formado de múltiples fuentes y periodos
-- y ha sido diseñado especificamente para resolver una pregunta. En contraposicion los datasets pueden no estar estructurados/enfocados
-- hacia resolver una pregunta especifica.