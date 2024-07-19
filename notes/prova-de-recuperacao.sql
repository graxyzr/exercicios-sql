-- Recuperação de Banco de Dados - Valor: 9,0
-- Nome: Greice Pereira - 2C
-- Data: 05/12/2023

-- 1) Gráfico do percentual de ocupação diária nos últimos 120 dias.

SELECT h.entrada::date AS Dia, 
    REPEAT('*', FLOOR((COUNT(h.codigo)* 100) / (SELECT COUNT(*) FROM quarto))::integer) || ' (' || CAST(ROUND((COUNT(h.codigo)* 100.0) / (SELECT COUNT(*) FROM quarto), 2) AS VARCHAR) || '%)' as gráfico
FROM hospedagem AS h
WHERE h.entrada >= CURRENT_DATE - INTERVAL '120 day'
GROUP BY Dia
ORDER BY Dia DESC;


-- 2) Percentual de ocupação semanal nos últimos 3 semestres por tipo de quarto.

SELECT t.nome AS tipo,
    TO_CHAR(DATE_TRUNC('week', h.entrada)::date, 'DD/MM/YYYY') || ' a ' || TO_CHAR((DATE_TRUNC('week', h.entrada) + INTERVAL '6 days')::date, 'DD/MM/YYYY') AS semana, 
    CONCAT(ROUND((COUNT(DISTINCT h.codigo) * 100.0 / COUNT(DISTINCT q.codigo)), 2), '%') AS percentual
FROM tipo t 
    JOIN quarto q ON t.codigo = q.tipo 
    LEFT JOIN hospedagem h ON q.codigo = h.quarto AND h.entrada BETWEEN (CURRENT_DATE - INTERVAL '1.5 YEARS') AND CURRENT_DATE 
GROUP BY t.nome, semana 
ORDER BY semana DESC, t.nome;


-- 3) Mês do ano com a maior quantidade de reservas por tipo de quarto nos últimos 5 anos.

SELECT tipo.nome,
    CASE 
        when EXTRACT(MONTH FROM reserva.inicio) = 1 then 'janeiro' 
        when EXTRACT(MONTH FROM reserva.inicio) = 2 then 'fevereiro' 
        when EXTRACT(MONTH FROM reserva.inicio) = 3 then 'marco'
        when EXTRACT(MONTH FROM reserva.inicio) = 4 then 'abril'
        when EXTRACT(MONTH FROM reserva.inicio) = 5 then 'maio'
        when EXTRACT(MONTH FROM reserva.inicio) = 6 then 'junho'
        when EXTRACT(MONTH FROM reserva.inicio) = 7 then 'julho'     
        when EXTRACT(MONTH FROM reserva.inicio) = 8 then 'agosto'
        when EXTRACT(MONTH FROM reserva.inicio) = 9 then 'setembro'
        when EXTRACT(MONTH FROM reserva.inicio) = 10 then 'outubro'
        when EXTRACT(MONTH FROM reserva.inicio) = 11 then 'novembro'
        when EXTRACT(MONTH FROM reserva.inicio) = 12 then 'dezembro'
    END as mes, COUNT(*) as reservas
FROM reserva
    JOIN tipo ON reserva.tipo = tipo.codigo
WHERE reserva.inicio BETWEEN (CURRENT_DATE - INTERVAL '5 YEARS') AND CURRENT_DATE
GROUP BY tipo.nome, mes
ORDER BY reservas DESC;


-- 4) Quartos que foram ocupados por hospedes de 5 ou mais UFs diferentes nos últimos 10 finais de semana.

SELECT q.andar, q.quarto
FROM quarto AS q
    JOIN hospedagem AS h ON q.codigo = h.quarto
    JOIN cliente AS c ON h.cliente = c.cpf
WHERE h.entrada BETWEEN (CURRENT_DATE - INTERVAL '70 DAYS') AND CURRENT_DATE
GROUP BY q.andar, q.quarto
HAVING COUNT(DISTINCT c.uf) >= 5;