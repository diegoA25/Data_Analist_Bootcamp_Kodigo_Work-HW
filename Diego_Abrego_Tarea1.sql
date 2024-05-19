/* Tarea 1 Ejercicios de introduccion a SQL y Joins Diego Eduardo Abrego Cornejo */
-- Query Ejercicio 1 
 /* Datos a usar: replacement_cost, title, amount Tabla a usar: film y amount rental e inventory son solo para conexion entre tablas*/
SELECT DISTINCT title                      AS movie_title
       ,replacement_cost
       ,amount                              AS price
       ,COUNT (*) OVER (PARTITION BY title) AS qty_available_in_inventory
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
WHERE replacement_cost < 4 * amount
ORDER BY replacement_cost, amount;
--Nota 1: Se despliega tambien la cantidad de peliculas del mismo titulo en el inventario
-- Query Ejercicio 2 
 /* Datos a usar: release_year, amount, replacement_cost, length, rating, rating, rental_duration, category, title. Tablas a usar: film, film_list. Solo mostrar title de las peliculas. */
SELECT  DISTINCT f.title                      AS movie_title
       ,COUNT (*) OVER (PARTITION BY f.title) AS qty_available_in_inventory
FROM film_list fl
JOIN film f
ON f.film_id = fl.fid
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
WHERE f.release_year = '2006'
AND p.amount BETWEEN 0.99 AND 2.99
AND f.replacement_cost < 19.99
AND fl.length BETWEEN 90 AND 150
AND (f.rating = 'G' OR f.rating = 'PG' OR f.rating = 'PG-13')
AND f.rental_duration <= 5
AND (fl.category = 'Comedy' OR fl.category = 'Family' OR fl.category = 'Children')
ORDER BY f.title;
--Nota 1: Se despliega la cantidad de titulos en el inventario para hacer mas legible la tabla.
-- Query Ejercicio 3 
 /*Datos a usar: rental_date, Hora de renta, title, first_name, last_name, email, phone, address, zip code, city, country, name (empleado). Tablas a usar: customer_list, film, inventory, staff_list, rental*/
SELECT  TO_CHAR(rental_date,'DD-MM-YYYY') AS rental_date
       ,EXTRACT(HOUR
FROM rental_date) || ':' || EXTRACT(MINUTE
FROM rental_date) AS rental_time, title, cl.name, c.email, cl.phone, cl.address, cl."zip code", cl.city, cl.country, stfl.name AS staff_name
FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
INNER JOIN customer_list cl
ON r.customer_id = cl.id
INNER JOIN customer c
ON c.customer_id = cl.id
INNER JOIN staff_list stfl
ON r.staff_id = stfl.id
WHERE TO_CHAR(rental_date, 'DD-MM-YYYY') = '24-05-2005'
ORDER BY rental_date;
-- Query Ejercicio 4 
 /* los mismos del ejercicio anterior con la excepcion de los datos mostrados ahora se muestran menos datos del cliente pero mas del empleado que realizo la transaccion y no se muestra la pelicula que fue alquilada */
SELECT  TO_CHAR(rental_date,'DD-MM-YYYY') AS rental_date
       ,EXTRACT(HOUR
FROM rental_date) || ':' || EXTRACT(MINUTE
FROM rental_date) AS rental_time, cl.name, cl.phone, cl.country, stfl.name AS staff_name, stfl.phone, stfl.country
FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
INNER JOIN customer_list cl
ON r.customer_id = cl.id
INNER JOIN customer c
ON c.customer_id = cl.id
INNER JOIN staff_list stfl
ON r.staff_id = stfl.id
WHERE TO_CHAR(rental_date, 'DD-MM-YYYY') = '24-05-2005'
ORDER BY rental_date;
-- Query Ejercicio 5 
 /* Datos a usar: rental_date (solo mes y año), monto que se pago(segun tabla payment) Tablas a usar: rental, payment, film. recordar que debo mostrar 08-2005*/
SELECT  DISTINCT TO_CHAR(rental_date,'MM-YYYY') AS rental_date
       ,f.title                                 AS movie_title
       ,price
       ,amount                                  AS actual_amount_paid
       ,COUNT(*) OVER (PARTITION BY amount)     AS different_amount_paid_count
FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
INNER JOIN film_list fl
ON f.film_id = fl.fid
INNER JOIN payment p
ON r.rental_id = p.rental_id
WHERE TO_CHAR(rental_date, 'MM-YYYY') = '08-2005'
AND price <> amount
ORDER BY price;
--Nota 1: se despliegan los titulos de las peliculas debido a que la misma pelicula posee distintos montos de pago respecto al precio verdadero.
--Nota 2: la columna different_amount_paid_count cuenta las veces que se cometio dicho error de pago con dicha pelicula.