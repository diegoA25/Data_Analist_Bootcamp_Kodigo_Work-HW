-- Clase 26/02/24
/*registros fecha de renta y pagos efectuados*/
WITH tmp_rentas AS
(
    SELECT  TO_CHAR(DATE_TRUNC('month',rental_date),'YYYY-MM') AS mes_renta
           ,COUNT(*)                                           AS cantidad
    FROM rental
    GROUP BY  1
) , tmp_pagos AS
(
    SELECT  TO_CHAR(DATE_TRUNC('month',payment_date),'YYYY-MM') AS mes_pago
           ,SUM(amount)                                         AS total
    FROM payment
    GROUP BY  1
), tmp_fechas AS
(
    SELECT  mes_renta AS fechas
    FROM tmp_rentas
    UNION
    SELECT  mes_pago
    FROM tmp_pagos
)
SELECT  fechas
       ,coalesce(cantidad,0) AS cantidad_rentas
       ,coalesce(total,0)    AS total_pagos
FROM tmp_fechas
LEFT JOIN tmp_rentas
ON tmp_fechas.fechas = tmp_rentas.mes_renta
LEFT JOIN tmp_pagos
ON tmp_fechas.fechas = tmp_pagos.mes_pago

SELECT
    TO_CHAR(rental_timestamp, 'MM-DD-YYYY') AS dia,
    SUM(rental_count)
FROM
    dw_dvdrental.rental_fact
WHERE EXTRACT(MONTH FROM rental_timestamp) = 7
GROUP BY
    dia
ORDER BY
    dia;
SELECT
    TO_CHAR(rental_timestamp, 'MM-DD-YYYY') AS dia,
    SUM(rental_count)
FROM
    dw_dvdrental.rental_fact
WHERE EXTRACT(MONTH FROM rental_timestamp) = 7
and EXTRACT(YEAR FROM rental_timestamp) = 2005
GROUP BY
    dia
ORDER BY
    dia;