-- Por: Lina Quintero, David Ballesteros, Felipe Clement

-- 7. Dividir la tabla PAYMENT en dos tablas. Una con los pagos del año 2005 y otra con los pagos de año 2006.
-- Cada tabla tendrá los siguientes campos: customer_id, amount, payment_date.
-- -    La tabla PAYMENT2005 debe llenarse con los pagos de rentas cuyas películas tienen tiempos de renta > a 3 días
-- -    La tabla PAYMENT2006 debe llenarse con los pagos de rentas cuyas películas tienen tiempos de renta <= a 3 días
-- -    Una vez tengamos las dos tablas con sus correspondientes registros se debe crear una tabla temporal llamada PAYMENTS 2005_2006 con la unión entre ellas.

drop table if exists PAYMENT2005;
drop table if exists PAYMENT2006;
drop table if exists PAYMENTS_2005_2006;

create table PAYMENT2005 as (
	select
		re.customer_id,
		pa.amount, pa.payment_date
    from payment as pa
    inner join rental as re on pa.rental_id = re.rental_id
    inner join inventory as inv on re.inventory_id = inv.inventory_id
    inner join film as fi on inv.film_id = fi.film_id
    where fi.rental_duration > 3
    and year(pa.payment_date) = 2005
);

create table PAYMENT2006 as (
	select
		re.customer_id,
		pa.amount, pa.payment_date
    from payment as pa
    inner join rental as re on pa.rental_id = re.rental_id
    inner join inventory as inv on re.inventory_id = inv.inventory_id
    inner join film as fi on inv.film_id = fi.film_id
    where fi.rental_duration <= 3
    and year(pa.payment_date) = 2006
);

create table PAYMENTS_2005_2006 as (
	select * from PAYMENT2005
    union
    select * from PAYMENT2006
);

select * from PAYMENTS_2005_2006 order by payment_date, customer_id;

