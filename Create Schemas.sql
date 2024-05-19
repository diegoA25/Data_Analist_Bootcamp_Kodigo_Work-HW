/* Paso 1

CREATE schema for dvdrental datawarehouse */

CREATE SCHEMA IF NOT EXISTS dw_dvdrental AUTHORIZATION pg_database_owner; COMMENT
ON SCHEMA dw_dvdrental IS 'datawarehouse for dvd rental'; GRANT USAGE
ON SCHEMA dw_dvdrental TO PUBLIC; GRANT ALL
ON SCHEMA dw_dvdrental TO pg_database_owner; 
/* Paso 2 Crear una dimension de calendario */

CREATE TABLE IF NOT EXISTS dw_dvdrental.calendar_dim ( date_col DATE PRIMARY KEY, year_col INTEGER, month_col INTEGER, yyyy_mm_col CHAR(6) )TABLESPACE pg_default;
ALTER TABLE IF EXISTS dw_dvdrental.calendar_dim OWNER to postgres; 
/* Paso 3 Poblar la dimension de calendario */
INSERT INTO dw_dvdrental.calendar_dim (date_col, year_col, month_col, yyyy_mm_col)
SELECT  generate_series('2005-01-01'::date,'2005-12-31'::date,'1 day'::interval)::date
       ,EXTRACT(YEAR
FROM generate_series
('2005-01-01'::date, '2005-12-31'::date, '1 day'::interval
)::date)::INTEGER, EXTRACT(MONTH
FROM generate_series
('2005-01-01'::date, '2005-12-31'::date, '1 day'::interval
)::date)::INTEGER, TO_CHAR(generate_series('2005-01-01'::date, '2005-12-31'::date, '1 day'::interval)::date, 'YYYYMM')::CHAR(6); 
/* Paso 4 Crear una dimension de direccion */

CREATE TABLE IF NOT EXISTS dw_dvdrental.address_dim ( address_id integer NOT NULL, address character varying(50) COLLATE pg_catalog."default", district character varying(50) COLLATE pg_catalog."default", city character varying(50) COLLATE pg_catalog."default", country character varying(50) COLLATE pg_catalog."default", postal_code character varying(10) COLLATE pg_catalog."default", phone character varying(20) COLLATE pg_catalog."default", CONSTRAINT address_dim_pkey PRIMARY KEY (address_id) )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.address_dim OWNER to postgres; /* Paso 5 poblar la dimension de direccion */
INSERT INTO dw_dvdrental.address_dim (address_id, address, district, city, country, postal_code, phone)
SELECT  address_id
       ,address
       ,district
       ,city
       ,country
       ,postal_code
       ,phone
FROM public.address
JOIN public.city
ON address.city_id = city.city_id
JOIN public.country
ON city.country_id = country.country_id; /* Paso 6 Crear una dimension de cliente */

CREATE TABLE IF NOT EXISTS dw_dvdrental.customer_dim ( customer_id integer NOT NULL, first_name character varying(45) COLLATE pg_catalog."default", last_name character varying(45) COLLATE pg_catalog."default", full_name character varying(90) COLLATE pg_catalog."default", email character varying(50) COLLATE pg_catalog."default", address_id integer, activebool boolean, create_date date, address character varying(50) COLLATE pg_catalog."default", district character varying(50) COLLATE pg_catalog."default", postal_code character varying(10) COLLATE pg_catalog."default", city character varying(50) COLLATE pg_catalog."default", country character varying(50) COLLATE pg_catalog."default", CONSTRAINT customer_dim_pkey PRIMARY KEY (customer_id) )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.customer_dim OWNER to postgres;
INSERT INTO dw_dvdrental.customer_dim (customer_id, first_name, last_name, full_name, email, address_id, activebool, create_date, address, district, postal_code, city, country) /* Paso 7 Poblar la dimension de cliente */
SELECT  customer_id
       ,first_name
       ,last_name
       ,first_name || ' ' || last_name
       ,email
       ,customer.address_id
       ,activebool
       ,create_date
       ,address
       ,district
       ,postal_code
       ,city
       ,country
FROM public.customer
JOIN dw_dvdrental.address_dim
ON customer.address_id = address_dim.address_id; /* Paso 8 Crear una dimension de pelicula */

CREATE TABLE IF NOT EXISTS dw_dvdrental.film_dim ( film_id integer NOT NULL, title character varying(255) COLLATE pg_catalog."default", description text COLLATE pg_catalog."default", release_year integer, language character varying(20) COLLATE pg_catalog."default", rental_duration integer, rental_rate numeric(4, 2), length integer, rating character varying(5) COLLATE pg_catalog."default", CONSTRAINT film_dim_pkey PRIMARY KEY (film_id) )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.film_dim OWNER to postgres; /* Paso 9 Poblar la dimension de pelicula */
INSERT INTO dw_dvdrental.film_dim (film_id, title, description, release_year, language, rental_duration, rental_rate, length, rating)
SELECT  film_id
       ,title
       ,description
       ,release_year
       ,language.name
       ,rental_duration
       ,rental_rate
       ,length
       ,rating
FROM public.film
JOIN public.language
ON film.language_id = language.language_id; /* Paso 10 Crear una dimension de store */

CREATE TABLE IF NOT EXISTS dw_dvdrental.store_dim ( store_id integer NOT NULL, address_id integer NOT NULL, address character varying(50) COLLATE pg_catalog."default", district character varying(50) COLLATE pg_catalog."default", postal_code character varying(10) COLLATE pg_catalog."default", city character varying(50) COLLATE pg_catalog."default", country character varying(50) COLLATE pg_catalog."default", CONSTRAINT store_dim_pkey PRIMARY KEY (store_id) )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.store_dim OWNER to postgres; /* Paso 11 Poblar la dimension de store */
INSERT INTO dw_dvdrental.store_dim (store_id, address_id, address, district, postal_code, city, country)
SELECT  store_id
       ,store.address_id
       ,address
       ,district
       ,postal_code
       ,city
       ,country
FROM public.store
JOIN dw_dvdrental.address_dim
ON store.address_id = address_dim.address_id; /* Paso 12 Crear una dimension de employee */

CREATE TABLE IF NOT EXISTS dw_dvdrental.employee_dim ( employee_id integer NOT NULL, first_name character varying(45) COLLATE pg_catalog."default", last_name character varying(45) COLLATE pg_catalog."default", full_name character varying(90) COLLATE pg_catalog."default", email character varying(50) COLLATE pg_catalog."default", address_id integer, activebool boolean, address character varying(50) COLLATE pg_catalog."default", phone character varying(20) COLLATE pg_catalog."default", district character varying(50) COLLATE pg_catalog."default", postal_code character varying(10) COLLATE pg_catalog."default", city character varying(50) COLLATE pg_catalog."default", country character varying(50) COLLATE pg_catalog."default", CONSTRAINT employee_dim_pkey PRIMARY KEY (employee_id) )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.employee_dim OWNER to postgres; /* Paso 13 Poblar la dimension de employee */
INSERT INTO dw_dvdrental.employee_dim (employee_id, first_name, last_name, full_name, email, address_id, activebool, address, phone, district, postal_code, city, country)
SELECT  staff_id
       ,first_name
       ,last_name
       ,first_name || ' ' || last_name
       ,email
       ,staff.address_id
       ,active
       ,address
       ,phone
       ,district
       ,postal_code
       ,city
       ,country
FROM public.staff
JOIN dw_dvdrental.address_dim
ON staff.address_id = address_dim.address_id; /* Paso 14 Crear una fact TABLE de rental */

CREATE TABLE IF NOT EXISTS dw_dvdrental.rental_fact ( rental_id serial NOT NULL, rental_timestamp timestamp without time zone NOT NULL, return_date date, customer_id integer, store_id integer, employee_id integer, film_id integer, date_col date, rental_count integer, rental_duration_real integer, amount numeric(5, 2), CONSTRAINT rental_fact_pkey PRIMARY KEY (rental_id), CONSTRAINT rental_fact_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES dw_dvdrental.customer_dim (customer_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON
DELETE NO ACTION, CONSTRAINT rental_fact_date_key_fkey FOREIGN KEY (date_col) REFERENCES dw_dvdrental.calendar_dim (date_col) MATCH SIMPLE
ON UPDATE NO ACTION
ON
DELETE NO ACTION, CONSTRAINT rental_fact_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES dw_dvdrental.employee_dim (employee_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON
DELETE NO ACTION, CONSTRAINT rental_fact_store_id_fkey FOREIGN KEY (store_id) REFERENCES dw_dvdrental.store_dim (store_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON
DELETE NO ACTION, CONSTRAINT rental_fact_film_id_fkey FOREIGN KEY (film_id) REFERENCES dw_dvdrental.film_dim (film_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON
DELETE NO ACTION )TABLESPACE pg_default;

ALTER TABLE IF EXISTS dw_dvdrental.rental_fact OWNER to postgres; /* Paso 15 Poblar la fact TABLE de rental */
INSERT INTO dw_dvdrental.rental_fact ( rental_timestamp, return_date, customer_id, store_id, employee_id, film_id, date_col, rental_count, rental_duration_real, amount)
SELECT  r.rental_date
       ,r.return_date
       ,r.customer_id
       ,i.store_id
       ,r.staff_id
       ,i.film_id
       ,d.date_col
       ,COUNT(r.rental_id)
       ,EXTRACT(DAY
FROM r.return_date - r.rental_date) , SUM(p.amount)
FROM public.rental r
JOIN public.payment p
ON r.rental_id = p.rental_id
JOIN PUBLIC.inventory i
ON r.inventory_id = i.inventory_id
JOIN dw_dvdrental.calendar_dim d
ON r.rental_date::date = d.date_col
GROUP BY  r.rental_date
         ,r.return_date
         ,r.customer_id
         ,i.store_id
         ,r.staff_id
         ,i.film_id
         ,d.date_col; /*¿Cuántos DVDs se han rentado cada día del mes de julio de 2005?*/

SELECT  film_id
       ,date_col
       ,rental_count
FROM dw_dvdrental.rental_fact
WHERE date_col BETWEEN '2005-07-01' AND '2007-07-31'
ORDER BY date_col;

SELECT  TO_CHAR(rental_timestamp,'MM-DD-YYYY') AS dia
       ,SUM(rental_count)
FROM dw_dvdrental.rental_fact
WHERE EXTRACT(MONTH
FROM rental_timestamp) = 7 AND EXTRACT(YEAR
FROM rental_timestamp) = 2005
GROUP BY  dia
ORDER BY  dia; 
/*¿Cuántos DVDs se han rentado cada día del mes de julio de 2005 por cada succursal?*/
SELECT  store_id
       ,SUM(rental_count)
FROM dw_dvdrental.rental_fact
WHERE EXTRACT(MONTH
FROM rental_timestamp) = 7 AND EXTRACT(YEAR
FROM rental_timestamp) = 2005
GROUP BY  store_id
ORDER BY  store_id; 
/*¿Cuántos DVDs se han rentado por mes
         ,empleado y país del cliente en el año 2005?*/
SELECT  clientes.country AS pais_cliente
        ,empleados.full_name AS nombre_empleado
       ,SUM(rentas) AS rentas
FROM
(
	SELECT  to_char(rental_timestamp,'YYYY-MM') AS mes
	       ,customer_id
           ,employee_id
	       ,SUM(rental_count)
	FROM dw_dvdrental.rental_fact
	WHERE EXTRACT(YEAR
	FROM rental_timestamp) = 2005
	GROUP BY  to_char(rental_timestamp,'YYYY-MM')
	         ,customer_id
             ,employee_id
)AS rentas
JOIN dw_dvdrental.customer_dim AS clientes
ON rentas.customer_id = clientes.customer_id
JOIN dw.dvdrental.employee_dim AS employee
ON rentas.employee_id = empleados.employee_id
GROUP BY  country;

