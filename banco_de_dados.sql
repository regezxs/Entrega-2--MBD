-- ============================================================
-- ENTREGA 2 — MODELO LÓGICO + IMPLEMENTAÇÃO SQL
-- Odontologia Sasaki
-- SGBD: MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS odontologia_sasaki;
CREATE DATABASE odontologia_sasaki
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE odontologia_sasaki;

-- ============================================================
-- 1. TABELAS PRINCIPAIS
-- ============================================================

CREATE TABLE consultorio (
    id_consultorio INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    localizacao VARCHAR(150) NOT NULL,
    status ENUM('Ativo','Inativo') NOT NULL DEFAULT 'Ativo',
    UNIQUE (nome)
);

CREATE TABLE funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    cargo VARCHAR(80) NOT NULL,
    cro VARCHAR(30) NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(150),
    endereco VARCHAR(255),
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(180) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE material (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    estoque_atual DECIMAL(12,2) NOT NULL DEFAULT 0,
    estoque_minimo DECIMAL(12,2) NOT NULL DEFAULT 0,
    validade DATE NULL,
    UNIQUE (nome),
    CHECK (estoque_atual >= 0),
    CHECK (estoque_minimo >= 0)
);

CREATE TABLE equipamento (
    id_equipamento INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipamento VARCHAR(150) NOT NULL,
    tipo_equipamento VARCHAR(100) NOT NULL,
    numero_serie VARCHAR(100) NOT NULL UNIQUE,
    data_aquisicao DATE NOT NULL,
    status ENUM('Disponível','Em Manutenção','Inativo','Em uso') NOT NULL DEFAULT 'Disponível',
    id_consultorio INT NOT NULL,
    id_funcionario_responsavel INT NULL,
    CONSTRAINT fk_equip_consultorio
        FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
    CONSTRAINT fk_equip_funcionario
        FOREIGN KEY (id_funcionario_responsavel) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE manutencao (
    id_manutencao INT AUTO_INCREMENT PRIMARY KEY,
    id_equipamento INT NOT NULL,
    id_funcionario INT NOT NULL,
    tipo ENUM('Preventiva','Corretiva') NOT NULL,
    data_manutencao DATE NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    custo DECIMAL(12,2) NOT NULL DEFAULT 0,
    proxima_manutencao DATE NULL,
    CONSTRAINT fk_manut_equipamento
        FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento),
    CONSTRAINT fk_manut_funcionario
        FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
    CHECK (custo >= 0)
);

-- ============================================================
-- 2. ATIVIDADE-FIM DA CLÍNICA
-- ============================================================

CREATE TABLE agendamento (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_funcionario_dentista INT NOT NULL,
    id_consultorio INT NOT NULL,
    data_hora DATETIME NOT NULL,
    status ENUM('Agendado','Confirmado','Realizado','Cancelado','Faltou') NOT NULL DEFAULT 'Agendado',
    observacao VARCHAR(500),
    CONSTRAINT fk_ag_paciente
        FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_ag_dentista
        FOREIGN KEY (id_funcionario_dentista) REFERENCES funcionario(id_funcionario),
    CONSTRAINT fk_ag_consultorio
        FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
    UNIQUE (id_funcionario_dentista, data_hora),
    UNIQUE (id_consultorio, data_hora)
);

CREATE TABLE atendimento (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL UNIQUE,
    data_atendimento DATETIME NOT NULL,
    anamnese TEXT,
    observacoes TEXT,
    CONSTRAINT fk_atendimento_agendamento
        FOREIGN KEY (id_agendamento) REFERENCES agendamento(id_agendamento)
);

CREATE TABLE procedimento (
    id_procedimento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao VARCHAR(500),
    valor_padrao DECIMAL(12,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (nome),
    CHECK (valor_padrao >= 0)
);

CREATE TABLE atendimento_procedimento (
    id_atendimento INT NOT NULL,
    id_procedimento INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_cobrado DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_atendimento, id_procedimento),
    FOREIGN KEY (id_atendimento) REFERENCES atendimento(id_atendimento),
    FOREIGN KEY (id_procedimento) REFERENCES procedimento(id_procedimento),
    CHECK (quantidade > 0),
    CHECK (valor_cobrado >= 0)
);

CREATE TABLE plano_tratamento (
    id_plano INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_funcionario_dentista INT NOT NULL,
    data_criacao DATE NOT NULL,
    status ENUM('Em elaboração','Aguardando aprovação','Aprovado','Recusado','Concluído') NOT NULL DEFAULT 'Em elaboração',
    valor_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    observacao VARCHAR(500),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_funcionario_dentista) REFERENCES funcionario(id_funcionario),
    CHECK (valor_total >= 0)
);

CREATE TABLE plano_procedimento (
    id_plano INT NOT NULL,
    id_procedimento INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_plano, id_procedimento),
    FOREIGN KEY (id_plano) REFERENCES plano_tratamento(id_plano),
    FOREIGN KEY (id_procedimento) REFERENCES procedimento(id_procedimento),
    CHECK (quantidade > 0),
    CHECK (valor_unitario >= 0)
);

CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_plano INT NULL,
    data_pagamento DATE NOT NULL,
    valor DECIMAL(12,2) NOT NULL,
    forma_pagamento ENUM('PIX','Dinheiro','Cartão de Crédito','Cartão de Débito','Boleto') NOT NULL,
    status ENUM('Pendente','Pago','Cancelado') NOT NULL DEFAULT 'Pago',
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_plano) REFERENCES plano_tratamento(id_plano),
    CHECK (valor > 0)
);

-- ============================================================
-- 3. ESTOQUE, COMPRAS E PRODUÇÃO
-- ============================================================

CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedor INT NOT NULL,
    data_compra DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    status ENUM('Aberta','Recebida','Cancelada') NOT NULL DEFAULT 'Recebida',
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor),
    CHECK (valor_total >= 0)
);

CREATE TABLE item_compra (
    id_compra INT NOT NULL,
    id_material INT NOT NULL,
    quantidade DECIMAL(12,2) NOT NULL,
    valor_unitario DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_compra, id_material),
    FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
    FOREIGN KEY (id_material) REFERENCES material(id_material),
    CHECK (quantidade > 0),
    CHECK (valor_unitario >= 0)
);

CREATE TABLE movimentacao_estoque (
    id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
    id_material INT NOT NULL,
    id_funcionario INT NOT NULL,
    tipo ENUM('Entrada','Saída') NOT NULL,
    quantidade DECIMAL(12,2) NOT NULL,
    data_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_material) REFERENCES material(id_material),
    FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
    CHECK (quantidade > 0)
);

CREATE TABLE producao (
    id_producao INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    tipo_produto ENUM('Implante','Aparelho Ortodôntico','Impressão 3D','Prótese','Outro') NOT NULL,
    quantidade INT NOT NULL,
    status ENUM('Aberta','Em produção','Concluída','Cancelada') NOT NULL DEFAULT 'Aberta',
    FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
    CHECK (quantidade > 0)
);

CREATE TABLE item_producao (
    id_producao INT NOT NULL,
    id_material INT NOT NULL,
    quantidade_utilizada DECIMAL(12,2) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_producao, id_material),
    FOREIGN KEY (id_producao) REFERENCES producao(id_producao),
    FOREIGN KEY (id_material) REFERENCES material(id_material),
    CHECK (quantidade_utilizada > 0)
);

-- ============================================================
-- 4. ESTERILIZAÇÃO
-- ============================================================

CREATE TABLE esterilizacao (
    id_esterilizacao INT AUTO_INCREMENT PRIMARY KEY,
    id_equipamento INT NOT NULL,
    id_funcionario INT NOT NULL,
    data_ciclo DATETIME NOT NULL,
    temperatura DECIMAL(5,2) NOT NULL,
    pressao DECIMAL(6,2),
    resultado ENUM('Aprovado','Reprovado') NOT NULL,
    observacao VARCHAR(500),
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento),
    FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
    CHECK (temperatura > 0)
);

-- ============================================================
-- 5. MASSA DE DADOS FICTÍCIA
-- ============================================================

INSERT INTO consultorio (nome, localizacao) VALUES
('Consultório 01','Térreo - Sala 01'),
('Consultório 02','Térreo - Sala 02'),
('Consultório 03','Térreo - Sala 03'),
('Laboratório CAD/CAM','Setor de Produção'),
('Sala de Esterilização','Setor Técnico');

INSERT INTO funcionario (nome, cpf, cargo, cro, telefone, email) VALUES
('Ana Souza','11111111101','Dentista','CRO-SP-10001','11980000001','ana@exemplo.com'),
('Bruno Lima','11111111102','Dentista','CRO-SP-10002','11980000002','bruno@exemplo.com'),
('Carla Mendes','11111111103','Auxiliar','', '11980000003','carla@exemplo.com'),
('Diego Alves','11111111104','Técnico de Manutenção',NULL,'11980000004','diego@exemplo.com'),
('Elisa Martins','11111111105','Recepcionista',NULL,'11980000005','elisa@exemplo.com');

INSERT INTO paciente (nome, cpf, data_nascimento, telefone, email, endereco) VALUES
('Paciente Fictício 01','22222222201','1995-03-12','11970000001','pac01@exemplo.com','São Paulo - SP'),
('Paciente Fictício 02','22222222202','1988-07-21','11970000002','pac02@exemplo.com','São Paulo - SP'),
('Paciente Fictício 03','22222222203','2001-11-05','11970000003','pac03@exemplo.com','São Paulo - SP'),
('Paciente Fictício 04','22222222204','1979-01-30','11970000004','pac04@exemplo.com','São Paulo - SP'),
('Paciente Fictício 05','22222222205','1992-09-18','11970000005','pac05@exemplo.com','São Paulo - SP');

INSERT INTO fornecedor (razao_social, cnpj, telefone, email) VALUES
('Fornecedor Fictício Dental Ltda','33333333000101','1130000001','fornecedor1@exemplo.com'),
('Fornecedor Fictício Medical Ltda','33333333000102','1130000002','fornecedor2@exemplo.com');

INSERT INTO material (nome, categoria, unidade_medida, estoque_atual, estoque_minimo, validade) VALUES
('Resina Odontológica','Resina','kg',4,5,'2027-06-30'),
('Filamento para Impressão 3D','Impressão 3D','kg',10,5,'2027-12-31'),
('Luva Descartável','EPI','caixa',25,10,'2028-01-31'),
('Máscara Cirúrgica','EPI','caixa',8,10,'2028-02-28'),
('Broca Odontológica','Instrumento','un',30,10,NULL);

INSERT INTO equipamento
(nome_equipamento,tipo_equipamento,numero_serie,data_aquisicao,status,id_consultorio,id_funcionario_responsavel)
VALUES
('Cadeira Odontológica','Cadeira','EQ-001','2024-01-10','Disponível',1,1),
('Scanner Intraoral','Scanner','EQ-002','2024-02-15','Em uso',2,1),
('Impressora 3D Odontológica','Impressora 3D','EQ-003','2024-03-20','Disponível',4,4),
('Autoclave','Esterilização','EQ-004','2023-10-05','Em uso',5,3),
('Aparelho de Raio-X','Raio-X','EQ-005','2023-05-18','Em Manutenção',3,2),
('Compressor de Ar','Compressor','EQ-006','2022-08-10','Inativo',1,4);

INSERT INTO manutencao
(id_equipamento,id_funcionario,tipo,data_manutencao,descricao,custo,proxima_manutencao)
VALUES
(1,4,'Preventiva','2026-01-15','Revisão geral',350,'2027-01-15'),
(2,4,'Preventiva','2026-02-20','Calibração do scanner',250,'2027-02-20'),
(5,4,'Corretiva','2026-10-10','Falha no equipamento de raio-X',800,'2027-04-10');

INSERT INTO agendamento
(id_paciente,id_funcionario_dentista,id_consultorio,data_hora,status,observacao)
VALUES
(1,1,'1','2026-10-20 09:00:00','Realizado','Avaliação inicial'),
(2,2,2,'2026-10-21 10:00:00','Realizado','Retorno'),
(3,1,1,'2026-10-22 14:00:00','Confirmado','Limpeza'),
(4,2,3,'2026-10-23 15:00:00','Cancelado','Cancelamento solicitado pelo paciente'),
(5,1,2,'2026-10-24 09:30:00','Agendado','Consulta de avaliação');

INSERT INTO atendimento
(id_agendamento,data_atendimento,anamnese,observacoes)
VALUES
(1,'2026-10-20 09:15:00','Sem alergias informadas','Avaliação realizada.'),
(2,'2026-10-21 10:10:00','Histórico atualizado','Retorno realizado.');

INSERT INTO procedimento (nome,descricao,valor_padrao) VALUES
('Avaliação Odontológica','Consulta de avaliação',150),
('Limpeza','Profilaxia odontológica',180),
('Restauração','Procedimento restaurador',250),
('Implante','Procedimento de implante',2500),
('Aparelho Ortodôntico','Instalação de aparelho',1800);

INSERT INTO atendimento_procedimento VALUES
(1,1,1,150),
(2,3,1,250);

INSERT INTO plano_tratamento
(id_paciente,id_funcionario_dentista,data_criacao,status,valor_total,observacao)
VALUES
(1,1,'2026-10-20','Aprovado',2650,'Plano de tratamento fictício'),
(2,2,'2026-10-21','Aguardando aprovação',1800,'Plano de tratamento fictício'),
(3,1,'2026-10-22','Em elaboração',180,'Plano inicial');

INSERT INTO plano_procedimento VALUES
(1,3,1,250),
(1,4,1,2400),
(2,5,1,1800),
(3,2,1,180);

INSERT INTO pagamento
(id_paciente,id_plano,data_pagamento,valor,forma_pagamento,status)
VALUES
(1,1,'2026-10-21',2650,'PIX','Pago'),
(2,2,'2026-10-22',900,'Cartão de Crédito','Pago'),
(3,3,'2026-10-23',180,'Dinheiro','Pendente');

INSERT INTO compra (id_fornecedor,data_compra,valor_total,status) VALUES
(1,'2026-10-01',600,'Recebida'),
(2,'2026-10-05',450,'Recebida');

INSERT INTO item_compra VALUES
(1,1,10,40),
(1,2,5,40),
(2,3,10,25),
(2,4,10,20);

INSERT INTO movimentacao_estoque
(id_material,id_funcionario,tipo,quantidade,motivo)
VALUES
(1,4,'Entrada',10,'Compra recebida'),
(2,4,'Entrada',5,'Compra recebida'),
(3,3,'Saída',2,'Uso operacional'),
(4,3,'Saída',4,'Uso operacional'),
(5,3,'Saída',5,'Uso clínico');

INSERT INTO producao
(id_funcionario,data_inicio,data_fim,tipo_produto,quantidade,status)
VALUES
(4,'2026-10-01','2026-10-03','Impressão 3D',5,'Concluída'),
(4,'2026-10-10',NULL,'Aparelho Ortodôntico',2,'Em produção');

INSERT INTO item_producao VALUES
(1,2,2.5,'kg'),
(2,1,1.0,'kg');

INSERT INTO esterilizacao
(id_equipamento,id_funcionario,data_ciclo,temperatura,pressao,resultado,observacao)
VALUES
(4,3,'2026-10-20 08:00:00',134,2.1,'Aprovado','Ciclo normal'),
(4,3,'2026-10-21 08:00:00',134,2.1,'Aprovado','Ciclo normal'),
(4,3,'2026-10-22 08:00:00',132,2.0,'Reprovado','Temperatura abaixo do parâmetro esperado');

-- ============================================================
-- 6. SELECT COM JOIN
-- ============================================================

SELECT
    e.id_equipamento,
    e.nome_equipamento,
    e.status,
    c.nome AS consultorio,
    f.nome AS responsavel
FROM equipamento e
JOIN consultorio c ON c.id_consultorio = e.id_consultorio
LEFT JOIN funcionario f ON f.id_funcionario = e.id_funcionario_responsavel;

SELECT
    p.nome AS paciente,
    a.data_hora,
    f.nome AS dentista,
    c.nome AS consultorio,
    a.status
FROM agendamento a
JOIN paciente p ON p.id_paciente = a.id_paciente
JOIN funcionario f ON f.id_funcionario = a.id_funcionario_dentista
JOIN consultorio c ON c.id_consultorio = a.id_consultorio
ORDER BY a.data_hora;

-- ============================================================
-- 7. UPDATE E DELETE
-- ============================================================

UPDATE equipamento
SET status = 'Disponível'
WHERE id_equipamento = 3;

UPDATE material
SET estoque_minimo = 12
WHERE id_material = 3;

-- Exemplo seguro de DELETE: somente registro fictício criado para teste.
-- DELETE FROM agendamento WHERE id_agendamento = 5;

-- ============================================================
-- 8. CONSULTAS GERENCIAIS
-- ============================================================

-- G01 — Quantos atendimentos foram realizados por mês?
-- Atende: gestão da atividade-fim.
SELECT
    DATE_FORMAT(a.data_atendimento,'%Y-%m') AS mes,
    COUNT(*) AS atendimentos_realizados
FROM atendimento a
GROUP BY DATE_FORMAT(a.data_atendimento,'%Y-%m')
ORDER BY mes;

-- G02 — Quais produtos/materiais estão abaixo do estoque mínimo?
-- Atende: P1 — dificuldade de controle de estoque.
SELECT
    id_material,
    nome,
    estoque_atual,
    estoque_minimo,
    (estoque_minimo - estoque_atual) AS quantidade_faltante
FROM material
WHERE estoque_atual < estoque_minimo
ORDER BY quantidade_faltante DESC;

-- G03 — Qual o faturamento por forma de pagamento?
-- Atende: KPI financeiro.
SELECT
    forma_pagamento,
    SUM(valor) AS faturamento
FROM pagamento
WHERE status = 'Pago'
GROUP BY forma_pagamento
ORDER BY faturamento DESC;

-- G04 — Qual o total recebido por mês?
-- Atende: KPI de arrecadação.
SELECT
    DATE_FORMAT(data_pagamento,'%Y-%m') AS mes,
    SUM(valor) AS total_recebido
FROM pagamento
WHERE status = 'Pago'
GROUP BY DATE_FORMAT(data_pagamento,'%Y-%m')
ORDER BY mes;

-- G05 — Quais equipamentos estão em manutenção?
-- Atende: P2 — dificuldade no acompanhamento da situação operacional.
SELECT
    e.nome_equipamento,
    e.numero_serie,
    c.nome AS consultorio,
    m.data_manutencao,
    m.tipo,
    m.descricao,
    m.proxima_manutencao
FROM equipamento e
JOIN consultorio c ON c.id_consultorio = e.id_consultorio
LEFT JOIN manutencao m ON m.id_equipamento = e.id_equipamento
WHERE e.status = 'Em Manutenção'
ORDER BY m.data_manutencao DESC;

-- G06 — Quantidade de equipamentos por status.
-- Atende: KPI de disponibilidade operacional.
SELECT
    status,
    COUNT(*) AS quantidade
FROM equipamento
GROUP BY status
ORDER BY quantidade DESC;

-- G07 — Número de agendamentos por situação.
-- Atende: KPI de ocupação/agenda.
SELECT
    status,
    COUNT(*) AS quantidade
FROM agendamento
GROUP BY status
ORDER BY quantidade DESC;

-- G08 — Valor médio dos pagamentos realizados.
-- Atende: KPI financeiro.
SELECT
    AVG(valor) AS ticket_medio
FROM pagamento
WHERE status = 'Pago';

-- G09 — Produção por tipo de produto.
-- Atende: acompanhamento da produção interna.
SELECT
    tipo_produto,
    SUM(quantidade) AS quantidade_produzida
FROM producao
WHERE status = 'Concluída'
GROUP BY tipo_produto;

-- G10 — Custo acumulado de manutenção por equipamento.
-- Atende: P3 — histórico/custos de manutenção.
SELECT
    e.nome_equipamento,
    COUNT(m.id_manutencao) AS qtd_manutencoes,
    COALESCE(SUM(m.custo),0) AS custo_total
FROM equipamento e
LEFT JOIN manutencao m ON m.id_equipamento = e.id_equipamento
GROUP BY e.id_equipamento, e.nome_equipamento
ORDER BY custo_total DESC;

-- G11 — Taxa de cancelamento dos agendamentos.
-- Atende: KPI de eficiência da agenda.
SELECT
    ROUND(
        100 * SUM(CASE WHEN status = 'Cancelado' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0), 2
    ) AS taxa_cancelamento_percentual
FROM agendamento;

-- G12 — Ciclos de esterilização reprovados.
-- Atende: controle de esterilização.
SELECT
    DATE(data_ciclo) AS data,
    COUNT(*) AS ciclos_reprovados
FROM esterilizacao
WHERE resultado = 'Reprovado'
GROUP BY DATE(data_ciclo)
ORDER BY data DESC;

-- ============================================================
-- 9. CONSULTAS DE AUDITORIA
-- ============================================================

-- A01 — Existe equipamento sem consultório?
-- Verifica: RN02.
SELECT *
FROM equipamento
WHERE id_consultorio IS NULL;

-- A02 — Existe equipamento em manutenção sem manutenção registrada?
-- Verifica: RN03/RN04.
SELECT e.*
FROM equipamento e
LEFT JOIN manutencao m ON m.id_equipamento = e.id_equipamento
WHERE e.status = 'Em Manutenção'
GROUP BY e.id_equipamento
HAVING COUNT(m.id_manutencao) = 0;

-- A03 — Existem materiais abaixo do estoque mínimo?
-- Verifica: controle de estoque.
SELECT *
FROM material
WHERE estoque_atual < estoque_minimo;

-- A04 — Existem agendamentos com conflito de dentista?
-- Verifica: regra de não sobreposição de agenda.
SELECT id_funcionario_dentista, data_hora, COUNT(*) AS ocorrencias
FROM agendamento
GROUP BY id_funcionario_dentista, data_hora
HAVING COUNT(*) > 1;

-- A05 — Existem agendamentos com conflito de consultório?
-- Verifica: regra de não sobreposição de consultório.
SELECT id_consultorio, data_hora, COUNT(*) AS ocorrencias
FROM agendamento
GROUP BY id_consultorio, data_hora
HAVING COUNT(*) > 1;

-- A06 — Existem dentistas sem CRO?
-- Verifica: requisito organizacional de registro profissional.
SELECT *
FROM funcionario
WHERE cargo = 'Dentista'
  AND (cro IS NULL OR TRIM(cro) = '');

-- A07 — Existem compras sem fornecedor cadastrado?
-- Verifica: RN de compras somente com fornecedor cadastrado.
SELECT c.*
FROM compra c
LEFT JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
WHERE f.id_fornecedor IS NULL;

-- A08 — Existem atendimentos sem paciente?
-- Verifica: integridade do prontuário/atendimento.
SELECT a.*
FROM atendimento a
LEFT JOIN agendamento ag ON ag.id_agendamento = a.id_agendamento
LEFT JOIN paciente p ON p.id_paciente = ag.id_paciente
WHERE p.id_paciente IS NULL;

-- A09 — Existem planos aprovados sem paciente?
-- Verifica: integridade do tratamento.
SELECT pt.*
FROM plano_tratamento pt
LEFT JOIN paciente p ON p.id_paciente = pt.id_paciente
WHERE p.id_paciente IS NULL;

-- A10 — Existem ciclos de esterilização reprovados?
-- Verifica: controle dos ciclos de esterilização.
SELECT *
FROM esterilizacao
WHERE resultado = 'Reprovado';

-- ============================================================
-- 10. VIEWS PARA DASHBOARD / BI
-- ============================================================

CREATE OR REPLACE VIEW vw_dashboard_equipamentos AS
SELECT
    status,
    COUNT(*) AS quantidade
FROM equipamento
GROUP BY status;

CREATE OR REPLACE VIEW vw_dashboard_estoque AS
SELECT
    id_material,
    nome,
    categoria,
    estoque_atual,
    estoque_minimo,
    CASE
        WHEN estoque_atual < estoque_minimo THEN 'Abaixo do mínimo'
        ELSE 'Normal'
    END AS situacao
FROM material;

CREATE OR REPLACE VIEW vw_dashboard_financeiro AS
SELECT
    DATE_FORMAT(data_pagamento,'%Y-%m') AS mes,
    forma_pagamento,
    SUM(CASE WHEN status = 'Pago' THEN valor ELSE 0 END) AS valor_pago,
    SUM(CASE WHEN status = 'Pendente' THEN valor ELSE 0 END) AS valor_pendente
FROM pagamento
GROUP BY DATE_FORMAT(data_pagamento,'%Y-%m'), forma_pagamento;

CREATE OR REPLACE VIEW vw_dashboard_agenda AS
SELECT
    DATE(data_hora) AS data,
    status,
    COUNT(*) AS quantidade
FROM agendamento
GROUP BY DATE(data_hora), status;

CREATE OR REPLACE VIEW vw_dashboard_manutencao AS
SELECT
    e.nome_equipamento,
    e.status,
    COUNT(m.id_manutencao) AS quantidade_manutencoes,
    COALESCE(SUM(m.custo),0) AS custo_total
FROM equipamento e
LEFT JOIN manutencao m ON m.id_equipamento = e.id_equipamento
GROUP BY e.id_equipamento, e.nome_equipamento, e.status;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
