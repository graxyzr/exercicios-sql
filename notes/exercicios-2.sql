-- 1) Quantas pizzas de tamanho grande ou família foram pedidas pela comanda 235?
SELECT COUNT(*) AS quantidade
FROM pizza
WHERE comanda = 235 AND tamanho IN ('F', 'G');



-- 2) Qual a quantidade de comandas não pagas na última semana?
SELECT COUNT(*) AS quantidade
FROM comanda
WHERE pago = 'F' AND DATA BETWEEN CURRENT_DATE - CAST((EXTRACT(DOW FROM CURRENT_DATE) + 7) || 'days' as interval) AND CURRENT_DATE - CAST((EXTRACT(DOW FROM CURRENT_DATE) + 1) || 'days' AS interval);

SELECT COUNT(*) AS quantidade
FROM comanda
WHERE pago = false AND data >= current_date - interval '7' day;



-- 3) Qual a quantidade média de ingredientes por sabor?
SELECT AVG(quantidade_ingredientes)
FROM (
    SELECT sabor, COUNT(ingrediente) AS quantidade_ingredientes
    FROM saboringrediente
    GROUP BY sabor
) AS ingredientes_por_sabor;
-- TALVEZ esteja correto



-- 4) Quantos sabores doces possuem mais de 8 ingredientes?
SELECT sabor.codigo, COUNT(*) AS quantidade
FROM saboringrediente
JOIN sabor ON saboringrediente.sabor = sabor.codigo
JOIN tipo ON sabor.tipo = tipo.codigo
WHERE LOWER(tipo.nome) LIKE '%doce%'
GROUP BY 1
HAVING COUNT(*) > 8;



-- 5) Quais dias tiveram mais de 10 comandas nos últimos 15 dias?
SELECT comanda.data
FROM comanda
WHERE data >= CURRENT_DATE - CAST('15 days' AS interval)
GROUP BY 1
HAVING COUNT(*) > 10;

SELECT data, COUNT(numero) as total_comandas
FROM comanda
WHERE data >= current_date - interval '15' day
GROUP BY data
HAVING COUNT(numero) > 10;



-- 6) Qual o ranking da quantidade de comandas por dia da semana no mês passado?
SELECT *
FROM comanda
WHERE date_trunc('month', data) = date_trunc('month', CURRENT_DATE - CAST('1 month' AS interval));

SELECT
    EXTRACT(DOW FROM data) AS dia_da_semana,
    COUNT(numero) AS total_comandas
FROM comanda
WHERE data >= current_date - interval '1' month
GROUP BY dia_da_semana
ORDER BY total_comandas DESC;



-- 7) Quais dias da semana tiveram menos de 20 comandas no mês passado?
SELECT *
FROM comanda
WHERE date_trunc('month', data) = date_trunc('month', CURRENT_DATE - CAST('1 month' AS interval)) AND comanda < 20;
--  O comando acima está dando erro



-- 8) Qual o ranking dos sabores mais pedidos nos últimos 15 dias?
SELECT sabor.nome, COUNT(*) AS quantidade
FROM comanda
JOIN pizza ON pizza.comanda = comanda.numero
JOIN pizzasabor ON pizzasabor.pizza = pizza.codigo
JOIN sabor ON pizzasabor.sabor = sabor.codigo
WHERE comanda.data > CURRENT_DATE - CAST('15 days' AS interval)
GROUP BY 1
ORDER BY 2 DESC;



-- 10) Quais sabores contém o ingrediente bacon?
SELECT *
FROM saboringrediente
JOIN ingrediente ON saboringrediente.ingrediente = ingrediente.codigo
JOIN sabor ON saboringrediente.sabor = sabor.codigo
WHERE LOWER(ingrediente.nome) LIKE '%bacon%';



-- 11) Quais sabores contém os ingredientes bacon e gorgonzola?
SELECT *
FROM saboringrediente
JOIN ingrediente ON saboringrediente.ingrediente = ingrediente.codigo
JOIN sabor ON saboringrediente.sabor = sabor.codigo
WHERE LOWER(ingrediente.nome) LIKE '%gorgon%';

INSERT INTO saboringrediente (sabor, ingrediente) VALUES (3, 20);



-- 12) Quais sabores salgados possuem mais de 8 ingredientes?
SELECT s.codigo, s.nome
FROM sabor s
JOIN saboringrediente si ON s.codigo = si.sabor
JOIN ingrediente i ON si.ingrediente = i.codigo
WHERE s.tipo = (SELECT codigo FROM tipo WHERE nome = 'Salgado')
GROUP BY s.codigo, s.nome
HAVING COUNT(DISTINCT i.codigo) > 8;
-- TALVEZ esteja correto



-- 13) Quais sabores salgados foram pedidos mais de 20 vezes no mês passado?
SELECT s.codigo, s.nome, COUNT(ps.sabor) AS total_pedidos
FROM sabor s
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
JOIN tipo t ON s.tipo = t.codigo
WHERE t.nome = 'Salgado' AND c.data >= current_date - interval '1' month
GROUP BY s.codigo, s.nome
HAVING COUNT(ps.sabor) > 20;
-- TALVEZ esteja correto



-- 14) Qual o ranking dos ingredientes mais pedidos nos últimos 12 meses?
SELECT
    i.codigo AS codigo_ingrediente,
    i.nome AS nome_ingrediente,
    COUNT(si.ingrediente) AS total_pedidos
FROM saboringrediente si
JOIN ingrediente i ON si.ingrediente = i.codigo
JOIN pizzasabor ps ON si.sabor = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '12' month
GROUP BY i.codigo, i.nome
ORDER BY total_pedidos DESC;
-- TALVEZ esteja correto



-- 15) Qual o ranking dos sabores doces mais pedidos nos últimos 12 meses por mês?
SELECT
    s.codigo AS codigo_sabor,
    s.nome AS nome_sabor,
    EXTRACT(MONTH FROM c.data) AS mes,
    COUNT(ps.sabor) AS total_pedidos
FROM sabor s
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
JOIN tipo t ON s.tipo = t.codigo
WHERE t.nome = 'Doce' AND c.data >= current_date - interval '12' month
GROUP BY s.codigo, s.nome, mes
ORDER BY mes, total_pedidos DESC;
-- TALVEZ esteja correto



-- 16) Qual a quantidade de pizzas pedidas por tipo por tamanho nos últimos 6 meses?
SELECT
    t.nome AS tipo,
    tamanho.nome AS tamanho,
    COUNT(p.codigo) AS total_pizzas
FROM tipo t
JOIN sabor s ON t.codigo = s.tipo
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN tamanho ON p.tamanho = tamanho.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '6' month
GROUP BY t.nome, tamanho.nome
ORDER BY t.nome, tamanho.nome;
-- TALVEZ esteja correto



-- 17) Qual o ranking dos ingredientes mais pedidos acompanhando cada borda nos últimos 6 meses?
SELECT
    b.nome AS nome_borda,
    i.codigo AS codigo_ingrediente,
    i.nome AS nome_ingrediente,
    COUNT(si.ingrediente) AS total_pedidos
FROM borda b
JOIN pizza p ON b.codigo = p.borda
JOIN pizzasabor ps ON p.codigo = ps.pizza
JOIN saboringrediente si ON ps.sabor = si.sabor
JOIN ingrediente i ON si.ingrediente = i.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '6' month
GROUP BY b.nome, i.codigo, i.nome
ORDER BY nome_borda, total_pedidos DESC;
-- TALVEZ esteja correto



-- 18) Qual sabor tem menos ingredientes?
SELECT s.codigo, s.nome, COUNT(si.ingrediente) AS total_ingredientes
FROM sabor s
JOIN saboringrediente si ON s.codigo = si.sabor
GROUP BY s.codigo, s.nome
ORDER BY total_ingredientes ASC
LIMIT 1;
-- TALVEZ esteja correto



-- 19) Qual sabor não foi pedido nos últimos 4 domingos?
SELECT s.codigo, s.nome
FROM sabor s
WHERE s.codigo NOT IN (
    SELECT DISTINCT ps.sabor
    FROM pizzasabor ps
    JOIN pizza p ON ps.pizza = p.codigo
    JOIN comanda c ON p.comanda = c.numero
    WHERE EXTRACT(DOW FROM c.data) = 0 AND c.data >= current_date - interval '4' week
);
-- O comando acima está dando erro de syntax



-- 20) Qual mesa foi menos utilizada nos últimos 60 dias?
SELECT mesa.codigo, mesa.nome
FROM mesa
LEFT JOIN comanda ON mesa.codigo = comanda.mesa
WHERE comanda.data >= current_date - interval '60' day OR comanda.data IS NULL
GROUP BY mesa.codigo, mesa.nome
ORDER BY COUNT(comanda.numero)
LIMIT 1;
-- TALVEZ esteja correto



-- 21) Qual o sabor mais pedido por tipo no ano passado?
SELECT
    s.codigo AS codigo_sabor,
    s.nome AS nome_sabor,
    t.nome AS tipo_sabor
FROM sabor s
JOIN tipo t ON s.tipo = t.codigo
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '1' year
GROUP BY s.codigo, s.nome, t.nome
HAVING COUNT(ps.sabor) = (
    SELECT COUNT(ps_inner.sabor)
    FROM pizzasabor ps_inner
    JOIN pizza p_inner ON ps_inner.pizza = p_inner.codigo
    JOIN comanda c_inner ON p_inner.comanda = c_inner.numero
    WHERE c_inner.data >= current_date - interval '1' year
    AND t.codigo = s.tipo
    GROUP BY ps_inner.sabor
    ORDER BY COUNT(ps_inner.sabor) DESC
    LIMIT 1
);
--  O comando acima está dando erro



-- 22) Quais mesas foram utilizadas mais de 2 vezes a média de utilização de todas as mesas nos últimos 60 dias?
SELECT mesa.codigo, mesa.nome
FROM mesa
JOIN comanda ON mesa.codigo = comanda.mesa
WHERE comanda.data >= current_date - interval '60' day
GROUP BY mesa.codigo, mesa.nome
HAVING COUNT(comanda.numero) > 2 * (
    SELECT AVG(utilizacao)
    FROM (
        SELECT COUNT(c.numero) AS utilizacao
        FROM mesa m
        LEFT JOIN comanda c ON m.codigo = c.mesa
        WHERE c.data >= current_date - interval '60' day
        GROUP BY m.codigo
    ) AS media_utilizacao
);
-- TALVEZ esteja correto



-- 23) Quais sabores estão entre os 10 mais pedidos no último mês e também no penúltimo mês?
SELECT
    s.codigo,
    s.nome
FROM sabor s
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE (EXTRACT(MONTH FROM c.data) = EXTRACT(MONTH FROM current_date - interval '1' month)
    OR EXTRACT(MONTH FROM c.data) = EXTRACT(MONTH FROM current_date - interval '2' month))
    AND EXTRACT(YEAR FROM c.data) = EXTRACT(YEAR FROM current_date)
GROUP BY s.codigo, s.nome
ORDER BY COUNT(c.numero) DESC
LIMIT 10;



-- 24) Quais sabores estão entre os 10 mais pedidos no último mês mas não no penúltimo mês?
SELECT
    s.codigo,
    s.nome
FROM sabor s
JOIN pizzasabor ps ON s.codigo = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE EXTRACT(MONTH FROM c.data) = EXTRACT(MONTH FROM current_date - interval '1' month)
    AND EXTRACT(YEAR FROM c.data) = EXTRACT(YEAR FROM current_date)
    AND s.codigo NOT IN (
        SELECT s.codigo
        FROM sabor s
        JOIN pizzasabor ps ON s.codigo = ps.sabor
        JOIN pizza p ON ps.pizza = p.codigo
        JOIN comanda c ON p.comanda = c.numero
        WHERE EXTRACT(MONTH FROM c.data) = EXTRACT(MONTH FROM current_date - interval '2' month)
            AND EXTRACT(YEAR FROM c.data) = EXTRACT(YEAR FROM current_date)
        GROUP BY s.codigo
        ORDER BY COUNT(c.numero) DESC
        LIMIT 10
    )
GROUP BY s.codigo, s.nome
ORDER BY COUNT(c.numero) DESC
LIMIT 10;



-- 25) Quais sabores não foram pedidos nos últimos 3 meses?
SELECT s.codigo, s.nome
FROM sabor s
WHERE s.codigo NOT IN (
    SELECT DISTINCT ps.sabor
    FROM pizzasabor ps
    JOIN pizza p ON ps.pizza = p.codigo
    JOIN comanda c ON p.comanda = c.numero
    WHERE c.data >= current_date - interval '3' month
);
-- TALVEZ esteja correto



-- 26) Quais foram os 5 ingredientes mais pedidos na última estação do ano?
SELECT
    ing.codigo,
    ing.nome
FROM ingrediente ing
JOIN saboringrediente si ON ing.codigo = si.ingrediente
JOIN pizzasabor ps ON si.sabor = ps.sabor
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE EXTRACT(QUARTER FROM c.data) = 4
    AND EXTRACT(YEAR FROM c.data) = EXTRACT(YEAR FROM current_date)
GROUP BY ing.codigo, ing.nome
ORDER BY COUNT(c.numero) DESC
LIMIT 5;



-- 27) Qual é o percentual atingido de arrecadação com venda de pizzas no ano atual em comparação com o total arrecadado no ano passado?
-- Não entendi



-- 28) Qual dia da semana teve maior arrecadação em pizzas nos últimos 60 dias?
SELECT
    EXTRACT(DOW FROM c.data) AS dia_da_semana,
    SUM(ppt.preco) AS arrecadacao
FROM precoportamanho ppt
JOIN pizza p ON ppt.tamanho = p.tamanho
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '60' day
GROUP BY EXTRACT(DOW FROM c.data)
ORDER BY arrecadacao DESC
LIMIT 1;
-- TALVEZ esteja correto



-- 29) Qual a combinação de 3 sabores mais pedida na mesma pizza nos últimos 3 meses?
SELECT
    ps1.sabor AS sabor1,
    ps2.sabor AS sabor2,
    ps3.sabor AS sabor3,
    COUNT(*) AS quantidade_pedidos
FROM pizzasabor ps1
JOIN pizzasabor ps2 ON ps1.pizza = ps2.pizza AND ps1.sabor < ps2.sabor
JOIN pizzasabor ps3 ON ps2.pizza = ps3.pizza AND ps2.sabor < ps3.sabor
JOIN comanda c ON ps1.pizza IN (SELECT pizza FROM comanda WHERE c.data >= current_date - interval '3' month)
WHERE c.data >= current_date - interval '3' month
GROUP BY sabor1, sabor2, sabor3
ORDER BY quantidade_pedidos DESC
LIMIT 1;
-- O comando acima está dando erro



-- 30) Qual a combinação de sabor e borda mais pedida na mesma pizza nos últimos 3 meses?
SELECT
    ps.sabor,
    p.borda,
    COUNT(*) AS quantidade_pedidos
FROM pizzasabor ps
JOIN pizza p ON ps.pizza = p.codigo
JOIN comanda c ON p.comanda = c.numero
WHERE c.data >= current_date - interval '3' month
GROUP BY ps.sabor, p.borda
ORDER BY quantidade_pedidos DESC
LIMIT 1;
-- TALVEZ esteja correto