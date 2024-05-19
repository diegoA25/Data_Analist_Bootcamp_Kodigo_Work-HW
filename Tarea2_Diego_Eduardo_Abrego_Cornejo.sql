-- Tarea 2 Diego Eduardo Abrego Cornejo
-- Problema 1
-- Mostrar clientes que hicieron más de una renta en un solo día, la cantidad de rentas registradas de ese cliente, los dias que fueron registradas
SELECT  cstmr.first_name || ' ' || cstmr.last_name AS customer_name
       ,rntl.rental_date::DATE                     AS rental_date
       ,COUNT(*)                                   AS rental_count
FROM customer cstmr
JOIN rental rntl
ON cstmr.customer_id = rntl.customer_id
GROUP BY  rntl.rental_date::DATE
         ,cstmr.first_name
         ,cstmr.last_name
HAVING COUNT(*) = 1 --Solo muestra cliente con nombres unicos en la tabla customer 
ORDER BY rental_date;
-- Problema 2
-- Contar cuantas transacciones de renta se hicieron en total por mes y pais del cliente 
SELECT  TO_CHAR(rntl.rental_date,'Month') AS month_of_rental
       ,ctry.country                      AS customer_country
       ,COUNT(*)                          AS transaction_count_by_month_and_country -- Cuenta las transacciones por mes y pais de cada cliente. 
FROM customer cstmr
JOIN rental rntl
ON cstmr.customer_id = rntl.customer_id
JOIN address a
ON cstmr.address_id = a.address_id
JOIN city cty
ON cty.city_id = a.city_id
JOIN country ctry
ON ctry.country_id = cty.country_id
GROUP BY  TO_CHAR(rntl.rental_date,'Month')
         ,ctry.country
ORDER BY  TO_CHAR(rntl.rental_date,'Month')
         ,ctry.country;
-- Problema 3
-- cual es el monto total pagado desagregado por año-mes (de pago), empleado que registro el pago y sucursal a la que pertenece
-- Las columnas a mostrar son "Año-Mes", codigo de empleado (PK de la tabla staff), Nombre completo del empleado, ciudad de la sucursal, y monto total pagado. 
SELECT  TO_CHAR(r.rental_date,'YYYY-MM')       AS year_month
       ,stf.staff_id                           AS employee_id
       ,stf.first_name || ' ' || stf.last_name AS employee_name
       ,cty.city                               AS store_city
       ,SUM(p.amount)                          AS total_amount_paid
FROM staff stf
JOIN store str
ON stf.store_id = str.store_id
JOIN rental r
ON r.staff_id = stf.staff_id
JOIN payment p
ON p.staff_id = stf.staff_id
JOIN address a
ON str.address_id = a.address_id
JOIN city cty
ON a.city_id = cty.city_id
GROUP BY  TO_CHAR(r.rental_date,'YYYY-MM')
         ,stf.staff_id
         ,cty.city
         ,stf.first_name
         ,stf.last_name
ORDER BY  TO_CHAR(r.rental_date,'YYYY-MM')
LIMIT 10;
-- Nota la query en visual studio code tarda alrededor de 20 minutos correr mejor correr la query en pgadmin4
-- Problema 4 (Adicional) 
SELECT  TO_CHAR(r.rental_date,'YYYY-MM')                                                                             AS year_month
       ,stf.staff_id                                                                                                 AS employee_id
       ,stf.first_name || ' ' || stf.last_name                                                                       AS employee_name
       ,cty.city                                                                                                     AS store_city
       ,COUNT(r.rental_id)                                                                                           AS total_rentals
       ,SUM(CASE WHEN TO_CHAR(r.rental_date,'YYYY-MM') = TO_CHAR(p.payment_date,'YYYY-MM') THEN p.amount ELSE 0 END) AS total_amount_paid
FROM staff stf
JOIN store str
ON stf.store_id = str.store_id
JOIN rental r
ON r.staff_id = stf.staff_id
JOIN payment p
ON p.staff_id = stf.staff_id
JOIN address a
ON str.address_id = a.address_id
JOIN city cty
ON a.city_id = cty.city_id
GROUP BY  TO_CHAR(r.rental_date,'YYYY-MM')
         ,stf.staff_id
         ,cty.city
         ,stf.first_name
         ,stf.last_name
ORDER BY  TO_CHAR(r.rental_date,'YYYY-MM')
LIMIT 10;

SELECT  TO_CHAR(DATE_TRUNC('month',rental_date),'YYYY-MM')  AS "Mes_renta"
       ,TO_CHAR(DATE_TRUNC('month',payment_date),'YYYY-MM') AS "Mes_renta_Payment"
FROM rental r
JOIN payment pa
ON r.rental_id = pa.rental_id
WHERE TO_CHAR(DATE_TRUNC('month', rental_date), 'YYYY-MM') <> TO_CHAR(DATE_TRUNC('month', payment_date), 'YYYY-MM')
-- Hacemos uso de un SUM(CASE) que calcula el monto total pagado para cada mes si la fecha de pago coincide con el año y mes de alquiler se suma el monto de pago y sino sumamos 0 para no afectar la suma