-- 1) 6: Quartos desocupados no último sábado 

SELECT andar, quarto
FROM quarto
WHERE codigo NOT IN (
  SELECT quarto
  FROM hospedagem
  WHERE (entrada <= (DATE_TRUNC('WEEK', CURRENT_DATE) - INTERVAL '1 WEEK') + INTERVAL '6 DAYS') 
    AND (saida IS NULL OR saida > (DATE_TRUNC('WEEK', CURRENT_DATE) - INTERVAL '1 WEEK') + INTERVAL '6 DAYS')
);



-- 2) Mês do ano com a maior quantidade de reservas nos últimos 5 anos

SELECT to_char(inicio, 'month') AS mes, COUNT(codigo) AS reservas
FROM reserva
WHERE inicio > (current_date - interval '5 YEARS') 
GROUP BY to_char(inicio, 'month')
ORDER BY reservas DESC
LIMIT 1;



-- 3) UFs com as 3 maiores quantidades de hospedagens nos últimos 3 semestres de 01/01 a 30/06 e de 01/07 a 31/12

SELECT uf, COUNT(h_semestre.cliente) AS hospedagens
FROM (
  SELECT cliente,
    CASE 
      WHEN EXTRACT(MONTH FROM entrada) BETWEEN 1 AND 6 
      THEN TO_CHAR(entrada, 'YYYY') || ' SEMESTRE 1'
      ELSE TO_CHAR(entrada, 'YYYY') || ' SEMESTRE 2' 
    END AS entrada_semestre
  FROM 
    hospedagem 
  WHERE 
    entrada >= (CURRENT_DATE - INTERVAL '18 MONTHS')
) AS h_semestre
JOIN cliente c ON h_semestre.cliente = c.cpf
GROUP BY uf
ORDER BY hospedagens DESC
LIMIT 3;



-- 4) Percentual de clientes que se hospedaram 4 ou mais vezes nos últimos 2 anos

SELECT ROUND((COUNT(DISTINCT cliente) * 100.0 / (SELECT COUNT(DISTINCT cliente)
FROM hospedagem
WHERE entrada >= NOW() - INTERVAL '2 YEARS')), 2) || '%' AS percentual
FROM (
    SELECT cliente, COUNT(cliente) as numero_reservas
    FROM hospedagem
    WHERE entrada >= NOW() - INTERVAL '2 years'
    GROUP BY cliente
    HAVING COUNT(cliente) >= 4
) AS subquery;