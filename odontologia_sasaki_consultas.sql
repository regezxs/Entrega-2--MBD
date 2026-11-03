-- ODONTOLOGIA SASAKI: G01-G12 e A01-A10
-- Execute APOS odontologia_sasaki_entrega_2_corrigido.sql
USE odontologia_sasaki;

-- ==================== 5. CONSULTAS GERENCIAIS G01-G12 ==================


-- G01 - Atendimentos realizados por mes
SELECT DATE_FORMAT(a.data_hora, '%Y-%m') AS mes,
       COUNT(*) AS total_atendimentos
FROM atendimento a
WHERE a.status = 'REALIZADO'
GROUP BY DATE_FORMAT(a.data_hora, '%Y-%m')
ORDER BY mes;

-- G02 - Materiais abaixo do estoque minimo
SELECT id_material, nome_material, quantidade_estoque, estoque_minimo
FROM vw_dashboard_estoque
WHERE situacao_estoque = 'ABAIXO_DO_MINIMO'
ORDER BY quantidade_estoque;

-- G03 - Receita recebida por forma de pagamento
SELECT forma_pagamento, COUNT(*) AS quantidade_pagamentos,
       SUM(valor_recebido) AS receita_recebida
FROM vw_dashboard_financeiro
WHERE status = 'PAGO'
GROUP BY forma_pagamento
ORDER BY receita_recebida DESC;

-- G04 - Total efetivamente recebido por mes
SELECT DATE_FORMAT(data_pagamento, '%Y-%m') AS mes,
       SUM(valor_recebido) AS total_recebido
FROM vw_dashboard_financeiro
WHERE status = 'PAGO'
GROUP BY DATE_FORMAT(data_pagamento, '%Y-%m')
ORDER BY mes;

-- G05 - Equipamentos em manutencao
SELECT id_equipamento, nome_equipamento, nome_consultorio, status
FROM vw_dashboard_equipamentos
WHERE status = 'EM_MANUTENCAO';

-- G06 - Equipamentos por status
SELECT status, COUNT(*) AS total
FROM vw_dashboard_equipamentos
GROUP BY status ORDER BY status;

-- G07 - Agendamentos por status
SELECT status, COUNT(*) AS total_agendamentos
FROM vw_dashboard_agenda
GROUP BY status ORDER BY status;

-- G08 - Media dos pagamentos recebidos
SELECT ROUND(AVG(valor_recebido), 2) AS media_pagamentos
FROM vw_dashboard_financeiro WHERE status = 'PAGO';

-- G09 - Producao por tipo
SELECT tipo_producao, COUNT(*) AS total_ordens,
       SUM(quantidade) AS unidades_produzidas
FROM producao
WHERE status = 'CONCLUIDA'
GROUP BY tipo_producao ORDER BY tipo_producao;

-- G10 - Custo de manutencao por equipamento
SELECT e.id_equipamento, e.nome_equipamento,
       COALESCE(SUM(m.custo), 0) AS custo_total
FROM equipamento e
LEFT JOIN manutencao m ON m.id_equipamento = e.id_equipamento
    AND m.status = 'CONCLUIDA'
GROUP BY e.id_equipamento, e.nome_equipamento
ORDER BY custo_total DESC;

-- G11 - Taxa de cancelamento da agenda (percentual)
SELECT COUNT(*) AS total_agendamentos,
       SUM(CASE WHEN status = 'CANCELADO' THEN 1 ELSE 0 END) AS cancelados,
       ROUND(100 * SUM(CASE WHEN status = 'CANCELADO' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0), 2) AS taxa_cancelamento_pct
FROM agendamento;

-- G12 - Falhas nos ciclos de esterilizacao
SELECT COUNT(*) AS total_ciclos,
       SUM(CASE WHEN status = 'FALHA' THEN 1 ELSE 0 END) AS ciclos_com_falha,
       ROUND(100 * SUM(CASE WHEN status = 'FALHA' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0), 2) AS taxa_falha_pct
FROM esterilizacao WHERE status IN ('CONCLUIDO','FALHA');

-- ==================== 6. AUDITORIAS A01-A10 ============================
-- Zero linhas pode significar nenhuma inconsistencia encontrada.

-- A01 - Equipamentos sem consultorio (protegido pela FK obrigatoria)
SELECT e.id_equipamento, e.nome_equipamento
FROM equipamento e LEFT JOIN consultorio c
    ON c.id_consultorio = e.id_consultorio
WHERE c.id_consultorio IS NULL;

-- A02 - Equipamentos marcados disponiveis com manutencao aberta
SELECT e.id_equipamento, e.nome_equipamento
FROM equipamento e
WHERE e.status = 'DISPONIVEL' AND EXISTS (
    SELECT 1 FROM manutencao m
    WHERE m.id_equipamento = e.id_equipamento AND m.status = 'ABERTA'
);

-- A03 - Materiais com estoque no minimo ou abaixo (alerta operacional)
SELECT id_material, nome_material, quantidade_estoque, estoque_minimo
FROM material WHERE quantidade_estoque <= estoque_minimo;

-- A04 - Pagamentos quitados sem data registrada
SELECT id_pagamento, id_atendimento
FROM pagamento WHERE status = 'PAGO' AND data_pagamento IS NULL;

-- A05 - Atendimentos realizados sem procedimentos registrados
SELECT a.id_atendimento, a.id_paciente
FROM atendimento a LEFT JOIN atendimento_procedimento ap
    ON ap.id_atendimento = a.id_atendimento
WHERE a.status = 'REALIZADO' AND ap.id_atendimento IS NULL;

-- A06 - Choque de horario em um mesmo consultorio (exclui cancelados)
SELECT id_consultorio, data_hora, COUNT(*) AS agendamentos_ativos
FROM agendamento WHERE status <> 'CANCELADO'
GROUP BY id_consultorio, data_hora HAVING COUNT(*) > 1;

-- A07 - Producoes concluidas sem registro de materiais utilizados
SELECT p.id_producao, p.descricao
FROM producao p LEFT JOIN item_producao ip
    ON ip.id_producao = p.id_producao
WHERE p.status = 'CONCLUIDA' AND ip.id_producao IS NULL;

-- A08 - Itens de compras recebidas sem a entrada de estoque correspondente
SELECT ic.id_compra, ic.id_material, ic.quantidade AS quantidade_comprada,
       COALESCE(SUM(me.quantidade),0) AS quantidade_recebida
FROM item_compra ic
JOIN compra c ON c.id_compra = ic.id_compra AND c.status = 'RECEBIDA'
LEFT JOIN movimentacao_estoque me
    ON me.id_compra = ic.id_compra
   AND me.id_material = ic.id_material
   AND me.tipo_movimentacao = 'ENTRADA'
GROUP BY ic.id_compra, ic.id_material, ic.quantidade
HAVING quantidade_recebida < quantidade_comprada;

-- A09 - Falhas de esterilizacao sem justificativa
SELECT id_esterilizacao, data_inicio, status
FROM esterilizacao
WHERE status = 'FALHA'
  AND (observacao IS NULL OR TRIM(observacao) = '');

-- A10 - Equipamentos com previsao de manutencao vencida e nao inativos
SELECT id_equipamento, nome_equipamento, proxima_manutencao, status
FROM equipamento
WHERE proxima_manutencao < CURRENT_DATE()
  AND status <> 'INATIVO';

