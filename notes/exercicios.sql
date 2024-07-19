-- 1) Liste todos os clientes que fizeram uma reserva e inclua as seguintes informações: nome do cliente, data de início e fim da reserva, quantidade de pessoas na reserva e o tipo de quarto reservado.

SELECT C.nome AS "Nome do Cliente",
       R.inicio AS "Data de Início da Reserva",
       R.fim AS "Data Final da Reserva",
       R.qtdepessoas AS "Quantidade de Pessoas na Reserva",
       T.nome AS "Tipo de Quarto Reservado"
FROM reserva R
JOIN cliente C ON R.cliente = C.cpf
JOIN tipo T ON R.tipo = T.codigo
LIMIT 4;


-- 2) Mostre os quartos disponíveis para hospedagem que possuem pelo menos uma cama de solteiro, ordenados pelo andar e número do quarto.

SELECT Q.codigo AS "Código do Quarto",
       Q.andar AS "Andar",
       Q.quarto AS "Número do Quarto"
FROM quarto Q
WHERE Q.camassolteiro > 0 
AND Q.codigo NOT IN (SELECT H.quarto FROM hospedagem H WHERE H.saida IS NULL)
ORDER BY Q.andar, Q.quarto;


-- 3) Retorne os tipos de quarto que têm um valor superior à média dos valores de todos os tipos de quarto.

SELECT T.codigo AS "Código do Tipo",
       T.nome AS "Nome do Tipo",
       T.valor AS "Valor do Tipo"
FROM tipo T
WHERE T.valor > (SELECT AVG(valor) FROM tipo);


-- 4) Para cada cliente, liste o número total de hospedagens realizadas e a quantidade total de pessoas que ele hospedou. Ordene os resultados pelo número total de hospedagens em ordem decrescente.

SELECT C.nome AS "Nome do Cliente",
       COUNT(H.codigo) AS "Total de Hospedagens",
       SUM(H.qtdepessoas) AS "Total de Pessoas Hospedadas"
FROM cliente C
JOIN hospedagem H ON C.cpf = H.cliente
GROUP BY C.nome
ORDER BY COUNT(H.codigo) DESC
LIMIT 4;


-- 5) Liste o código do quarto, a quantidade total de pessoas hospedadas nesse quarto e o valor total arrecadado com as hospedagens desse quarto. Ordene o resultado pelo valor total em ordem decrescente.

SELECT hospedagem.quarto AS Codigo_Quarto, SUM(hospedagem.qtdepessoas) AS Total_Pessoas, SUM(hospedagem.qtdepessoas * tipo.valor) AS Valor_Total
FROM hospedagem
    INNER JOIN quarto ON hospedagem.quarto = quarto.codigo
    INNER JOIN tipo ON quarto.tipo = tipo.codigo
GROUP BY hospedagem.quarto
ORDER BY Valor_Total DESC;


-- 6) Recupere o nome e o número de telefone de clientes que têm reserva para um quarto no qual o valor do tipo seja superior a R$ 200.00.

SELECT cliente.nome, cliente.telefone
FROM cliente
    INNER JOIN reserva ON cliente.cpf = reserva.cliente
    INNER JOIN tipo ON reserva.tipo = tipo.codigo
WHERE tipo.valor > 200;


-- 7) Obtenha a média de pessoas por reserva, agrupando por tipo de quarto. Mostre o nome do tipo de quarto e a média de pessoas para cada tipo.

SELECT tipo.nome AS Tipo_de_Quarto, AVG(reserva.qtdepessoas) AS Media_de_Pessoas
FROM reserva
    INNER JOIN tipo ON reserva.tipo = tipo.codigo
GROUP BY tipo.nome;


-- 8) Recupere o código do quarto, a data de entrada e a data de saída das hospedagens em que a quantidade de pessoas seja superior a 2 e a data de saída seja nula (indicando uma hospedagem ainda em curso).

SELECT quarto AS Codigo_Quarto, entrada AS Data_Entrada, saida AS Data_Saida
FROM hospedagem
WHERE qtdepessoas > 2 AND saida IS NULL;


-- 9) Liste o nome do cliente, a data de entrada e a data de saída das hospedagens, incluindo os casos em que não há hospedagem associada. Utilize LEFT JOIN e RIGHT JOIN conforme necessário.

SELECT cliente.nome AS Nome_Cliente, hospedagem.entrada AS Data_Entrada, hospedagem.saida AS Data_Saida
FROM cliente
    LEFT JOIN hospedagem ON cliente.cpf = hospedagem.cliente
LIMIT 10;


-- 10) Recupere o nome do cliente, a data de entrada e a data de saída da hospedagem mais recente para cada cliente que já realizou pelo menos uma hospedagem.

SELECT cliente.nome AS Nome_Cliente, hospedagem.entrada AS Data_Entrada, hospedagem.saida AS Data_Saida
FROM cliente
INNER JOIN (
    SELECT cliente, MAX(entrada) AS max_entrada
    FROM hospedagem
    GROUP BY cliente) hospedagem_recente
ON cliente.cpf = hospedagem_recente.cliente
    INNER JOIN hospedagem ON hospedagem.cliente = hospedagem_recente.cliente AND hospedagem.entrada = hospedagem_recente.max_entrada
LIMIT 10;


-- 11) Recupere o nome do cliente, a data de entrada e a data de saída das hospedagens que ocorreram nos últimos 30 dias.

SELECT cliente.nome AS Nome_Cliente, hospedagem.entrada AS Data_Entrada, hospedagem.saida AS Data_Saida
FROM hospedagem
    INNER JOIN cliente ON cliente.cpf = hospedagem.cliente
WHERE hospedagem.entrada BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
LIMIT 10;


-- 12) Obtenha a quantidade de reservas por tipo de quarto, incluindo apenas os tipos que tenham mais de 2 reservas.

SELECT tipo.nome AS Tipo_de_Quarto, COUNT(reserva.codigo) AS Quantidade_de_Reservas
FROM reserva
    INNER JOIN tipo ON reserva.tipo = tipo.codigo
GROUP BY Tipo_de_Quarto
HAVING COUNT(reserva.codigo) > 2;


-- 13) Recupere o código e a quantidade de pessoas das hospedagens em que a quantidade de pessoas seja maior que a média de pessoas de todas as hospedagens, ordenando pelo código da hospedagem.

SELECT codigo, qtdepessoas 
FROM hospedagem
WHERE qtdepessoas > (SELECT AVG(qtdepessoas) FROM hospedagem)
ORDER BY codigo
LIMIT 10;


-- 14) Tipo de quarto com a maior média de valores de hospedagem nos últimos 5 anos.

SELECT t.nome, AVG(h.qtdepessoas * t.valor) as media_valor_hospedage
FROM hospedagem h
    INNER JOIN quarto q ON h.quarto = q.codigo
    INNER JOIN tipo t ON q.tipo = t.codigo
WHERE h.entrada >= (CURRENT_DATE - INTERVAL '5 years')
GROUP BY t.nome
ORDER BY media_valor_hospedage DESC
LIMIT 1;


-- 15) Cidades com a maior quantidade de clientes nos últimos 3 anos.

SELECT c.cidade, COUNT(DISTINCT c.cpf) as quantidade_clientes
FROM cliente c
    INNER JOIN hospedagem h ON c.cpf = h.cliente
WHERE h.entrada >= (CURRENT_DATE - INTERVAL '3 years')
GROUP BY c.cidade
ORDER BY quantidade_clientes DESC
LIMIT 2;


-- 16) Quartos com a maior quantidade de hospedagens nos últimos 2 meses.

SELECT h.quarto, COUNT(*) as quantidade_hospedagens
FROM hospedagem h
WHERE h.entrada >= (CURRENT_DATE - INTERVAL '2 months')
GROUP BY h.quarto
ORDER BY quantidade_hospedagens DESC;


-- 17) Clientes que fizeram reservas nos últimos 3 meses e ainda não realizaram check-out.

SELECT c.nome, r.codigo as codigo_reserva
FROM cliente c
    INNER JOIN reserva r ON c.cpf = r.cliente
WHERE r.inicio >= (CURRENT_DATE - INTERVAL '3 months') AND r.fim IS NULL;


-- 18) Reservas canceladas nos últimos 6 meses.

SELECT r.codigo AS codigo_reserva
FROM reserva r
    LEFT JOIN hospedagem h ON r.cliente = h.cliente AND r.codigo = h.codigo
WHERE r.inicio >= (CURRENT_DATE - INTERVAL '6 months') AND (h.codigo IS NULL OR h.saida IS NOT NULL);