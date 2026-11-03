-- =====================================================================
-- ODONTOLOGIA SASAKI - ENTREGA 2
-- Modelo logico/fisico, integridade, dados ficticios, consultas e views
-- SGBD: MySQL 8.0.16+ (CHECK com aplicacao efetiva)
-- =====================================================================
-- Este script NAO remove bancos/tabelas existentes.
-- Execute preferencialmente em uma instancia sem um banco odontologia_sasaki
-- preexistente. Dados de exemplo usam IDs fixos e INSERT IGNORE para
-- evitar duplicacao em uma segunda execucao no ambiente de demonstracao.
-- =====================================================================

SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS odontologia_sasaki
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE odontologia_sasaki;

-- ==================== 1. ESTRUTURA (20 TABELAS) =======================

CREATE TABLE IF NOT EXISTS consultorio (
    id_consultorio BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_consultorio VARCHAR(120) NOT NULL,
    numero_sala VARCHAR(20) NOT NULL,
    andar SMALLINT NOT NULL,
    status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (id_consultorio),
    UNIQUE KEY uq_consultorio_sala (andar, numero_sala)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS funcionario (
    id_funcionario BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(150),
    data_admissao DATE NOT NULL,
    status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (id_funcionario),
    UNIQUE KEY uq_funcionario_cpf (cpf),
    UNIQUE KEY uq_funcionario_email (email),
    CONSTRAINT ck_funcionario_cpf CHECK (cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente (
    id_paciente BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11),
    data_nascimento DATE,
    telefone VARCHAR(20),
    email VARCHAR(150),
    endereco VARCHAR(250),
    convenio VARCHAR(100),
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_paciente),
    UNIQUE KEY uq_paciente_cpf (cpf),
    CONSTRAINT ck_paciente_cpf CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fornecedor (
    id_fornecedor BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    razao_social VARCHAR(150) NOT NULL,
    cnpj CHAR(14),
    telefone VARCHAR(20),
    email VARCHAR(150),
    endereco VARCHAR(250),
    status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (id_fornecedor),
    UNIQUE KEY uq_fornecedor_cnpj (cnpj),
    CONSTRAINT ck_fornecedor_cnpj CHECK (cnpj IS NULL OR cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS material (
    id_material BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_material VARCHAR(150) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    descricao TEXT,
    unidade_medida VARCHAR(30) NOT NULL,
    quantidade_estoque INT UNSIGNED NOT NULL DEFAULT 0,
    estoque_minimo INT UNSIGNED NOT NULL DEFAULT 0,
    valor_unitario_referencia DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    data_validade DATE,
    localizacao VARCHAR(100),
    status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (id_material),
    CONSTRAINT ck_material_valor CHECK (valor_unitario_referencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipamento (
    id_equipamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_consultorio BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NULL,
    nome_equipamento VARCHAR(150) NOT NULL,
    tipo_equipamento VARCHAR(100),
    numero_serie VARCHAR(100) NOT NULL,
    data_aquisicao DATE,
    ultima_manutencao DATE,
    proxima_manutencao DATE,
    status ENUM('DISPONIVEL','EM_MANUTENCAO','INATIVO') NOT NULL DEFAULT 'DISPONIVEL',
    PRIMARY KEY (id_equipamento),
    UNIQUE KEY uq_equipamento_numero_serie (numero_serie),
    KEY idx_equipamento_consultorio (id_consultorio),
    KEY idx_equipamento_responsavel (id_funcionario),
    CONSTRAINT fk_equipamento_consultorio FOREIGN KEY (id_consultorio)
        REFERENCES consultorio (id_consultorio),
    CONSTRAINT fk_equipamento_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS manutencao (
    id_manutencao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_equipamento BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    tipo_manutencao ENUM('PREVENTIVA','CORRETIVA','CALIBRACAO') NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_conclusao DATETIME NULL,
    descricao TEXT NOT NULL,
    observacao TEXT,
    custo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status ENUM('ABERTA','CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
    PRIMARY KEY (id_manutencao),
    KEY idx_manutencao_equipamento (id_equipamento),
    KEY idx_manutencao_funcionario (id_funcionario),
    CONSTRAINT fk_manutencao_equipamento FOREIGN KEY (id_equipamento)
        REFERENCES equipamento (id_equipamento),
    CONSTRAINT fk_manutencao_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT ck_manutencao_custo CHECK (custo >= 0),
    CONSTRAINT ck_manutencao_datas CHECK (data_conclusao IS NULL OR data_conclusao >= data_inicio),
    CONSTRAINT ck_manutencao_conclusao CHECK (status <> 'CONCLUIDA' OR data_conclusao IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS agendamento (
    id_agendamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_paciente BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    id_consultorio BIGINT UNSIGNED NOT NULL,
    data_hora DATETIME NOT NULL,
    status ENUM('AGENDADO','CONFIRMADO','REALIZADO','CANCELADO') NOT NULL DEFAULT 'AGENDADO',
    observacao TEXT,
    PRIMARY KEY (id_agendamento),
    KEY idx_agendamento_data (data_hora),
    KEY idx_agendamento_paciente (id_paciente),
    KEY idx_agendamento_funcionario (id_funcionario),
    KEY idx_agendamento_consultorio (id_consultorio, data_hora),
    CONSTRAINT fk_agendamento_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente),
    CONSTRAINT fk_agendamento_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT fk_agendamento_consultorio FOREIGN KEY (id_consultorio)
        REFERENCES consultorio (id_consultorio)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS atendimento (
    id_atendimento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_agendamento BIGINT UNSIGNED NULL,
    id_paciente BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    id_consultorio BIGINT UNSIGNED NOT NULL,
    data_hora DATETIME NOT NULL,
    status ENUM('EM_ANDAMENTO','REALIZADO','CANCELADO') NOT NULL DEFAULT 'EM_ANDAMENTO',
    descricao TEXT,
    PRIMARY KEY (id_atendimento),
    UNIQUE KEY uq_atendimento_agendamento (id_agendamento),
    KEY idx_atendimento_paciente (id_paciente),
    KEY idx_atendimento_funcionario (id_funcionario),
    KEY idx_atendimento_consultorio (id_consultorio),
    KEY idx_atendimento_data (data_hora),
    CONSTRAINT fk_atendimento_agendamento FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento) ON DELETE SET NULL,
    CONSTRAINT fk_atendimento_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente),
    CONSTRAINT fk_atendimento_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT fk_atendimento_consultorio FOREIGN KEY (id_consultorio)
        REFERENCES consultorio (id_consultorio)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS procedimento (
    id_procedimento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_procedimento VARCHAR(150) NOT NULL,
    descricao TEXT,
    valor_base DECIMAL(12,2) NOT NULL,
    duracao_estimada_min INT UNSIGNED,
    status ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (id_procedimento),
    CONSTRAINT ck_procedimento_valor CHECK (valor_base >= 0),
    CONSTRAINT ck_procedimento_duracao CHECK (duracao_estimada_min IS NULL OR duracao_estimada_min > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS atendimento_procedimento (
    id_atendimento BIGINT UNSIGNED NOT NULL,
    id_procedimento BIGINT UNSIGNED NOT NULL,
    quantidade SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(12,2) NOT NULL,
    valor_total DECIMAL(12,2) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    PRIMARY KEY (id_atendimento, id_procedimento),
    KEY idx_atend_proc_procedimento (id_procedimento),
    CONSTRAINT fk_atend_proc_atendimento FOREIGN KEY (id_atendimento)
        REFERENCES atendimento (id_atendimento),
    CONSTRAINT fk_atend_proc_procedimento FOREIGN KEY (id_procedimento)
        REFERENCES procedimento (id_procedimento),
    CONSTRAINT ck_atend_proc_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_atend_proc_valor CHECK (valor_unitario >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS plano_tratamento (
    id_plano BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_paciente BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    descricao TEXT NOT NULL,
    data_criacao DATE NOT NULL,
    data_conclusao DATE,
    status ENUM('PLANEJADO','EM_ANDAMENTO','CONCLUIDO','CANCELADO') NOT NULL DEFAULT 'PLANEJADO',
    PRIMARY KEY (id_plano),
    KEY idx_plano_paciente (id_paciente),
    KEY idx_plano_funcionario (id_funcionario),
    CONSTRAINT fk_plano_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente),
    CONSTRAINT fk_plano_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT ck_plano_datas CHECK (data_conclusao IS NULL OR data_conclusao >= data_criacao)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS plano_procedimento (
    id_plano BIGINT UNSIGNED NOT NULL,
    id_procedimento BIGINT UNSIGNED NOT NULL,
    quantidade SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    valor_previsto DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_plano, id_procedimento),
    KEY idx_plano_proc_procedimento (id_procedimento),
    CONSTRAINT fk_plano_proc_plano FOREIGN KEY (id_plano)
        REFERENCES plano_tratamento (id_plano),
    CONSTRAINT fk_plano_proc_procedimento FOREIGN KEY (id_procedimento)
        REFERENCES procedimento (id_procedimento),
    CONSTRAINT ck_plano_proc_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_plano_proc_valor CHECK (valor_previsto >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pagamento (
    id_pagamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_atendimento BIGINT UNSIGNED NOT NULL,
    data_pagamento DATETIME NULL,
    valor DECIMAL(12,2) NOT NULL,
    forma_pagamento ENUM('PIX','DINHEIRO','CARTAO_CREDITO','CARTAO_DEBITO','BOLETO','CONVENIO') NOT NULL,
    status ENUM('PENDENTE','PAGO','ESTORNADO','CANCELADO') NOT NULL DEFAULT 'PENDENTE',
    observacao TEXT,
    PRIMARY KEY (id_pagamento),
    KEY idx_pagamento_atendimento (id_atendimento),
    KEY idx_pagamento_data (data_pagamento),
    CONSTRAINT fk_pagamento_atendimento FOREIGN KEY (id_atendimento)
        REFERENCES atendimento (id_atendimento),
    CONSTRAINT ck_pagamento_valor CHECK (valor > 0),
    CONSTRAINT ck_pagamento_data CHECK (status <> 'PAGO' OR data_pagamento IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS compra (
    id_compra BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_fornecedor BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NULL,
    data_compra DATE NOT NULL,
    data_recebimento DATE NULL,
    status ENUM('ABERTA','RECEBIDA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
    observacao TEXT,
    PRIMARY KEY (id_compra),
    KEY idx_compra_fornecedor (id_fornecedor),
    KEY idx_compra_funcionario (id_funcionario),
    CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT fk_compra_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario) ON DELETE SET NULL,
    CONSTRAINT ck_compra_datas CHECK (data_recebimento IS NULL OR data_recebimento >= data_compra),
    CONSTRAINT ck_compra_recebimento CHECK (status <> 'RECEBIDA' OR data_recebimento IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS item_compra (
    id_compra BIGINT UNSIGNED NOT NULL,
    id_material BIGINT UNSIGNED NOT NULL,
    quantidade INT UNSIGNED NOT NULL,
    valor_unitario DECIMAL(12,2) NOT NULL,
    valor_total DECIMAL(12,2) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    PRIMARY KEY (id_compra, id_material),
    KEY idx_item_compra_material (id_material),
    CONSTRAINT fk_item_compra_compra FOREIGN KEY (id_compra)
        REFERENCES compra (id_compra),
    CONSTRAINT fk_item_compra_material FOREIGN KEY (id_material)
        REFERENCES material (id_material),
    CONSTRAINT ck_item_compra_qtd CHECK (quantidade > 0),
    CONSTRAINT ck_item_compra_valor CHECK (valor_unitario >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS producao (
    id_producao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    descricao VARCHAR(250) NOT NULL,
    tipo_producao ENUM('IMPLANTE','APARELHO_ORTODONTICO','IMPRESSAO_3D','OUTROS') NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_conclusao DATETIME NULL,
    quantidade INT UNSIGNED NOT NULL DEFAULT 1,
    status ENUM('PLANEJADA','EM_ANDAMENTO','CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'PLANEJADA',
    observacao TEXT,
    PRIMARY KEY (id_producao),
    KEY idx_producao_funcionario (id_funcionario),
    CONSTRAINT fk_producao_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT ck_producao_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_producao_datas CHECK (data_conclusao IS NULL OR data_conclusao >= data_inicio),
    CONSTRAINT ck_producao_conclusao CHECK (status <> 'CONCLUIDA' OR data_conclusao IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS item_producao (
    id_producao BIGINT UNSIGNED NOT NULL,
    id_material BIGINT UNSIGNED NOT NULL,
    quantidade_utilizada INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_producao, id_material),
    KEY idx_item_producao_material (id_material),
    CONSTRAINT fk_item_producao_producao FOREIGN KEY (id_producao)
        REFERENCES producao (id_producao),
    CONSTRAINT fk_item_producao_material FOREIGN KEY (id_material)
        REFERENCES material (id_material),
    CONSTRAINT ck_item_producao_qtd CHECK (quantidade_utilizada > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movimentacao_estoque (
    id_movimentacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_material BIGINT UNSIGNED NOT NULL,
    id_compra BIGINT UNSIGNED NULL,
    id_producao BIGINT UNSIGNED NULL,
    id_funcionario BIGINT UNSIGNED NULL,
    tipo_movimentacao ENUM('ENTRADA','SAIDA') NOT NULL,
    quantidade INT UNSIGNED NOT NULL,
    data_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(250),
    PRIMARY KEY (id_movimentacao),
    KEY idx_mov_material_data (id_material, data_movimentacao),
    KEY idx_mov_compra (id_compra),
    KEY idx_mov_producao (id_producao),
    KEY idx_mov_funcionario (id_funcionario),
    CONSTRAINT fk_mov_material FOREIGN KEY (id_material)
        REFERENCES material (id_material),
    CONSTRAINT fk_mov_compra FOREIGN KEY (id_compra)
        REFERENCES compra (id_compra),
    CONSTRAINT fk_mov_producao FOREIGN KEY (id_producao)
        REFERENCES producao (id_producao),
    CONSTRAINT fk_mov_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT ck_mov_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_mov_origem CHECK (
        (tipo_movimentacao = 'ENTRADA' AND id_producao IS NULL)
        OR (tipo_movimentacao = 'SAIDA' AND id_compra IS NULL)
    )
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS esterilizacao (
    id_esterilizacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_equipamento BIGINT UNSIGNED NOT NULL,
    id_funcionario BIGINT UNSIGNED NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NULL,
    tipo_ciclo VARCHAR(100) NOT NULL,
    status ENUM('EM_ANDAMENTO','CONCLUIDO','FALHA') NOT NULL DEFAULT 'EM_ANDAMENTO',
    observacao TEXT,
    PRIMARY KEY (id_esterilizacao),
    KEY idx_esterilizacao_equipamento (id_equipamento),
    KEY idx_esterilizacao_funcionario (id_funcionario),
    CONSTRAINT fk_esterilizacao_equipamento FOREIGN KEY (id_equipamento)
        REFERENCES equipamento (id_equipamento),
    CONSTRAINT fk_esterilizacao_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario),
    CONSTRAINT ck_esterilizacao_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT ck_esterilizacao_fim CHECK (status = 'EM_ANDAMENTO' OR data_fim IS NOT NULL)
) ENGINE=InnoDB;

-- ==================== 2. REGRAS DE NEGOCIO ============================
-- RN02: equipamento.id_consultorio obrigatorio (NOT NULL e FK).
-- RN03: manutencao.id_equipamento obrigatorio (NOT NULL e FK).
-- RN04: status EM_MANUTENCAO e verificacao na view de disponibilidade.
-- RN05: saida SEMPRE exige movimento; o saldo e alterado pela trigger.
-- RN06: producao so pode ser CONCLUIDA com itens em item_producao.
-- As movimentacoes sao imutaveis; correcao exige movimento compensatorio.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_equipamento_impede_disponivel_com_manutencao$$
CREATE TRIGGER trg_equipamento_impede_disponivel_com_manutencao
BEFORE UPDATE ON equipamento
FOR EACH ROW
BEGIN
    IF NEW.status = 'DISPONIVEL' AND EXISTS (
        SELECT 1 FROM manutencao m
        WHERE m.id_equipamento = NEW.id_equipamento AND m.status = 'ABERTA'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN04: equipamento com manutencao aberta nao pode estar disponivel';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_manutencao_abertura$$
CREATE TRIGGER trg_manutencao_abertura
AFTER INSERT ON manutencao
FOR EACH ROW
BEGIN
    IF NEW.status = 'ABERTA' THEN
        UPDATE equipamento SET status = 'EM_MANUTENCAO'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_manutencao_alteracao$$
CREATE TRIGGER trg_manutencao_alteracao
AFTER UPDATE ON manutencao
FOR EACH ROW
BEGIN
    IF NEW.status = 'ABERTA' THEN
        UPDATE equipamento SET status = 'EM_MANUTENCAO'
        WHERE id_equipamento = NEW.id_equipamento;
    ELSEIF OLD.status = 'ABERTA' AND NEW.status IN ('CONCLUIDA','CANCELADA') THEN
        UPDATE equipamento e
        SET e.status = 'DISPONIVEL'
        WHERE e.id_equipamento = NEW.id_equipamento
          AND e.status = 'EM_MANUTENCAO'
          AND NOT EXISTS (
              SELECT 1 FROM manutencao m
              WHERE m.id_equipamento = NEW.id_equipamento AND m.status = 'ABERTA'
          );
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_movimentacao_atualiza_saldo$$
CREATE TRIGGER trg_movimentacao_atualiza_saldo
AFTER INSERT ON movimentacao_estoque
FOR EACH ROW
BEGIN
    IF NEW.tipo_movimentacao = 'ENTRADA' THEN
        UPDATE material
        SET quantidade_estoque = quantidade_estoque + NEW.quantidade
        WHERE id_material = NEW.id_material;
    ELSE
        UPDATE material
        SET quantidade_estoque = quantidade_estoque - NEW.quantidade
        WHERE id_material = NEW.id_material
          AND quantidade_estoque >= NEW.quantidade;
        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN05: saldo insuficiente para saida de estoque';
        END IF;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_movimentacao_bloqueia_update$$
CREATE TRIGGER trg_movimentacao_bloqueia_update
BEFORE UPDATE ON movimentacao_estoque
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Movimentacao nao pode ser editada: lance movimento compensatorio';
END$$

DROP TRIGGER IF EXISTS trg_movimentacao_bloqueia_delete$$
CREATE TRIGGER trg_movimentacao_bloqueia_delete
BEFORE DELETE ON movimentacao_estoque
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Movimentacao nao pode ser excluida: lance movimento compensatorio';
END$$

DROP TRIGGER IF EXISTS trg_producao_exige_material_na_conclusao$$
CREATE TRIGGER trg_producao_exige_material_na_conclusao
BEFORE UPDATE ON producao
FOR EACH ROW
BEGIN
    IF NEW.status = 'CONCLUIDA' AND NOT EXISTS (
        SELECT 1 FROM item_producao ip
        WHERE ip.id_producao = NEW.id_producao
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN06: cadastre materiais antes de concluir a producao';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_producao_impede_conclusao_direta$$
CREATE TRIGGER trg_producao_impede_conclusao_direta
BEFORE INSERT ON producao
FOR EACH ROW
BEGIN
    IF NEW.status = 'CONCLUIDA' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN06: registre a producao, inclua os itens e depois conclua';
    END IF;
END$$

DELIMITER ;

-- ==================== 3. DADOS FICTICIOS ===============================
-- IDs fixos para simplificar a demonstracao das FK.
-- CPFs e CNPJs sao apenas exemplos de formato (nao documentos reais).

INSERT IGNORE INTO consultorio
(id_consultorio, nome_consultorio, numero_sala, andar, status) VALUES
(1,'Consultorio Clinico 1','101',1,'ATIVO'),
(2,'Consultorio Ortodontia','102',1,'ATIVO'),
(3,'Laboratorio de Proteses','201',2,'ATIVO'),
(4,'Consultorio Cirurgico','202',2,'ATIVO');

INSERT IGNORE INTO funcionario
(id_funcionario,nome,cpf,cargo,telefone,email,data_admissao,status) VALUES
(1,'Ana Ribeiro','00000000001','Dentista','11990000001','ana.ribeiro@exemplo.test','2024-03-10','ATIVO'),
(2,'Bruno Lopes','00000000002','Ortodontista','11990000002','bruno.lopes@exemplo.test','2023-08-14','ATIVO'),
(3,'Carla Ferreira','00000000003','Tecnica em Equipamentos','11990000003','carla.ferreira@exemplo.test','2025-01-20','ATIVO'),
(4,'Daniel Costa','00000000004','Recepcionista','11990000004','daniel.costa@exemplo.test','2025-06-03','ATIVO'),
(5,'Elisa Martins','00000000005','Tecnica em Saude Bucal','11990000005','elisa.martins@exemplo.test','2024-11-18','ATIVO');

INSERT IGNORE INTO paciente
(id_paciente,nome,cpf,data_nascimento,telefone,email,endereco,convenio) VALUES
(1,'Mariana Oliveira','11111111101','1998-04-02','11991110001','mariana@exemplo.test','Rua Ficticia 101','Unimed'),
(2,'Lucas Santos','11111111102','1989-08-19','11991110002','lucas@exemplo.test','Rua Ficticia 102',NULL),
(3,'Beatriz Lima','11111111103','2001-02-07','11991110003','beatriz@exemplo.test','Rua Ficticia 103','Amil'),
(4,'Joao Pereira','11111111104','1976-12-25','11991110004','joao@exemplo.test','Rua Ficticia 104',NULL),
(5,'Julia Rocha','11111111105','2010-09-12','11991110005','julia@exemplo.test','Rua Ficticia 105','SulAmerica'),
(6,'Rafael Almeida','11111111106','1994-07-10','11991110006','rafael@exemplo.test','Rua Ficticia 106',NULL),
(7,'Camila Souza','11111111107','1990-11-22','11991110007','camila@exemplo.test','Rua Ficticia 107','Amil'),
(8,'Felipe Martins','11111111108','1983-06-05','11991110008','felipe@exemplo.test','Rua Ficticia 108',NULL);

INSERT IGNORE INTO fornecedor
(id_fornecedor,razao_social,cnpj,telefone,email,endereco,status) VALUES
(1,'Dental Suprimentos Exemplo Ltda','00000000000001','1130000001','dental@exemplo.test','Avenida Ficticia 100','ATIVO'),
(2,'Insumos Odonto Exemplo Ltda','00000000000002','1130000002','insumos@exemplo.test','Avenida Ficticia 200','ATIVO'),
(3,'Tecnologia Protetica Exemplo Ltda','00000000000003','1130000003','protetica@exemplo.test','Avenida Ficticia 300','ATIVO');

INSERT IGNORE INTO material
(id_material,nome_material,categoria,descricao,unidade_medida,estoque_minimo,valor_unitario_referencia,data_validade,localizacao,status) VALUES
(1,'Pino para implante','Implantodontia','Pino para procedimento de implante','UN',10,80.00,'2028-12-31','A1','ATIVO'),
(2,'Fio ortodontico','Ortodontia','Fio para aparelho','UN',12,19.90,'2028-08-31','A2','ATIVO'),
(3,'Bracket metalico','Ortodontia','Componente de aparelho','UN',12,15.00,'2029-12-31','A3','ATIVO'),
(4,'Resina para impressao 3D','Laboratorio','Resina fotopolimerizavel','L',10,120.00,'2027-11-30','B1','ATIVO'),
(5,'Molde de silicone','Laboratorio','Material de moldagem','UN',8,32.00,'2027-06-30','B2','ATIVO'),
(6,'Componente de titanio','Implantodontia','Peca de titanio','UN',5,140.00,'2029-12-31','A4','ATIVO'),
(7,'Filamento para impressora 3D','Laboratorio','Material para impressao','KG',7,95.00,'2029-01-31','B3','ATIVO'),
(8,'Gesso odontologico','Laboratorio','Gesso de laboratorio','KG',8,22.00,'2028-05-31','B4','ATIVO');

INSERT IGNORE INTO procedimento
(id_procedimento,nome_procedimento,descricao,valor_base,duracao_estimada_min,status) VALUES
(1,'Avaliacao odontologica','Exame clinico inicial',180.00,45,'ATIVO'),
(2,'Limpeza dental','Profilaxia',220.00,50,'ATIVO'),
(3,'Implante dentario','Instalacao do implante',2500.00,120,'ATIVO'),
(4,'Manutencao ortodontica','Ajuste de aparelho',190.00,45,'ATIVO'),
(5,'Moldagem digital','Escaneamento e moldagem',300.00,50,'ATIVO'),
(6,'Restauracao','Restauracao dental',420.00,70,'ATIVO');

INSERT IGNORE INTO equipamento
(id_equipamento,id_consultorio,id_funcionario,nome_equipamento,tipo_equipamento,numero_serie,data_aquisicao,ultima_manutencao,proxima_manutencao,status) VALUES
(1,1,3,'Autoclave 01','Esterilizacao','AUTO-SAS-001','2024-02-01','2026-09-15','2026-12-15','DISPONIVEL'),
(2,2,3,'Cadeira Odontologica 02','Atendimento','CAD-SAS-002','2023-05-10','2026-05-10','2026-10-20','DISPONIVEL'),
(3,3,3,'Impressora 3D 01','Producao','IMP-SAS-003','2025-02-15','2026-10-01','2027-01-01','DISPONIVEL'),
(4,4,3,'Raio X 01','Diagnostico','RX-SAS-004','2024-09-09','2026-10-10','2027-01-10','DISPONIVEL'),
(5,3,3,'Scanner Laboratorial','Producao','SCN-SAS-005','2022-04-12','2025-04-12','2026-08-12','INATIVO');

INSERT IGNORE INTO manutencao
(id_manutencao,id_equipamento,id_funcionario,tipo_manutencao,data_inicio,data_conclusao,descricao,observacao,custo,status) VALUES
(1,2,3,'CORRETIVA','2026-10-20 08:00:00',NULL,'Revisao de motor da cadeira','Aguardando peca',350.00,'ABERTA'),
(2,1,3,'PREVENTIVA','2026-09-15 09:00:00','2026-09-15 11:00:00','Verificacao periodica de autoclave','Aprovada',180.00,'CONCLUIDA'),
(3,3,3,'CALIBRACAO','2026-10-01 08:00:00','2026-10-01 10:00:00','Calibracao da impressora','Sem falhas',120.00,'CONCLUIDA'),
(4,4,3,'PREVENTIVA','2026-10-10 08:00:00','2026-10-10 09:00:00','Inspecao do raio X','Normal',150.00,'CONCLUIDA');

INSERT IGNORE INTO agendamento
(id_agendamento,id_paciente,id_funcionario,id_consultorio,data_hora,status,observacao) VALUES
(1,1,1,1,'2026-09-05 09:00:00','REALIZADO',NULL),
(2,2,1,1,'2026-09-09 14:00:00','REALIZADO',NULL),
(3,3,2,2,'2026-09-15 10:00:00','REALIZADO',NULL),
(4,4,1,4,'2026-10-05 09:00:00','REALIZADO',NULL),
(5,5,2,2,'2026-10-10 11:00:00','REALIZADO',NULL),
(6,6,1,1,'2026-10-18 15:00:00','CANCELADO','Paciente solicitou cancelamento'),
(7,7,1,1,'2026-11-05 09:00:00','CONFIRMADO',NULL),
(8,8,2,2,'2026-11-10 14:00:00','AGENDADO',NULL);

INSERT IGNORE INTO atendimento
(id_atendimento,id_agendamento,id_paciente,id_funcionario,id_consultorio,data_hora,status,descricao) VALUES
(1,1,1,1,1,'2026-09-05 09:00:00','REALIZADO','Avaliacao inicial'),
(2,2,2,1,1,'2026-09-09 14:00:00','REALIZADO','Limpeza e avaliacao'),
(3,3,3,2,2,'2026-09-15 10:00:00','REALIZADO','Manutencao ortodontica'),
(4,4,4,1,4,'2026-10-05 09:00:00','REALIZADO','Implante dentario'),
(5,5,5,2,2,'2026-10-10 11:00:00','REALIZADO','Moldagem digital'),
(6,NULL,6,1,1,'2026-10-12 16:00:00','REALIZADO','Atendimento de urgencia'),
(7,NULL,7,1,1,'2026-10-22 14:00:00','EM_ANDAMENTO','Planejamento restaurador');

INSERT IGNORE INTO atendimento_procedimento
(id_atendimento,id_procedimento,quantidade,valor_unitario) VALUES
(1,1,1,180.00),(2,2,1,220.00),(2,1,1,180.00),
(3,4,1,190.00),(4,3,1,2500.00),(5,5,1,300.00),
(6,6,1,420.00),(7,1,1,180.00);

INSERT IGNORE INTO plano_tratamento
(id_plano,id_paciente,id_funcionario,descricao,data_criacao,data_conclusao,status) VALUES
(1,1,1,'Plano preventivo anual','2026-09-05',NULL,'EM_ANDAMENTO'),
(2,3,2,'Plano ortodontico','2026-09-15',NULL,'EM_ANDAMENTO'),
(3,4,1,'Implantodontia e acompanhamento','2026-10-05',NULL,'EM_ANDAMENTO'),
(4,5,2,'Plano de moldagem e aparelho','2026-10-10',NULL,'PLANEJADO'),
(5,7,1,'Plano restaurador','2026-10-22',NULL,'PLANEJADO');

INSERT IGNORE INTO plano_procedimento
(id_plano,id_procedimento,quantidade,valor_previsto) VALUES
(1,1,1,180.00),(1,2,2,220.00),
(2,4,6,190.00),(3,3,1,2500.00),(3,1,1,180.00),
(4,5,1,300.00),(4,4,3,190.00),(5,6,2,420.00);

INSERT IGNORE INTO pagamento
(id_pagamento,id_atendimento,data_pagamento,valor,forma_pagamento,status,observacao) VALUES
(1,1,'2026-09-05 10:00:00',180.00,'PIX','PAGO',NULL),
(2,2,'2026-09-09 15:00:00',200.00,'CARTAO_CREDITO','PAGO','Primeira parcela'),
(3,2,'2026-09-20 15:00:00',200.00,'CARTAO_CREDITO','PAGO','Segunda parcela'),
(4,3,'2026-09-15 11:00:00',190.00,'DINHEIRO','PAGO',NULL),
(5,4,'2026-10-05 12:00:00',1500.00,'PIX','PAGO','Entrada do implante'),
(6,4,NULL,1000.00,'BOLETO','PENDENTE','Saldo do implante'),
(7,5,'2026-10-10 12:00:00',300.00,'CARTAO_DEBITO','PAGO',NULL),
(8,6,'2026-10-12 17:00:00',420.00,'CONVENIO','PAGO',NULL),
(9,7,NULL,180.00,'PIX','PENDENTE',NULL),
(10,5,'2026-10-15 13:00:00',50.00,'PIX','ESTORNADO','Lancamento corrigido');

INSERT IGNORE INTO compra
(id_compra,id_fornecedor,id_funcionario,data_compra,data_recebimento,status,observacao) VALUES
(1,1,4,'2026-09-01','2026-09-04','RECEBIDA','Insumos gerais'),
(2,2,4,'2026-09-07','2026-09-09','RECEBIDA','Materiais de moldagem'),
(3,3,4,'2026-09-12','2026-09-14','RECEBIDA','Material de laboratorio'),
(4,1,4,'2026-10-25',NULL,'ABERTA','Pedido em transporte'),
(5,2,4,'2026-10-12',NULL,'CANCELADA','Fornecedor indisponivel');

INSERT IGNORE INTO item_compra
(id_compra,id_material,quantidade,valor_unitario) VALUES
(1,1,40,80.00),(1,2,30,19.90),(1,4,18,120.00),
(2,3,12,15.00),(2,5,8,32.00),
(3,6,5,140.00),(3,7,7,95.00),(3,8,10,22.00),
(4,1,10,82.00);

INSERT IGNORE INTO producao
(id_producao,id_funcionario,descricao,tipo_producao,data_inicio,data_conclusao,quantidade,status,observacao) VALUES
(1,3,'Confeccao de componente de implante','IMPLANTE','2026-10-01 08:00:00',NULL,5,'EM_ANDAMENTO',NULL),
(2,5,'Montagem de aparelho ortodontico','APARELHO_ORTODONTICO','2026-10-03 08:00:00',NULL,4,'EM_ANDAMENTO',NULL),
(3,3,'Impressao 3D de pecas','IMPRESSAO_3D','2026-10-07 09:00:00',NULL,3,'EM_ANDAMENTO',NULL),
(4,5,'Produzir modelo odontologico','OUTROS','2026-10-09 09:00:00',NULL,2,'EM_ANDAMENTO',NULL),
(5,3,'Producao experimental suspensa','IMPRESSAO_3D','2026-10-12 10:00:00',NULL,1,'CANCELADA',NULL);

INSERT IGNORE INTO item_producao
(id_producao,id_material,quantidade_utilizada) VALUES
(1,1,5),(1,6,3),
(2,2,4),(2,3,2),
(3,4,3),(3,7,2),
(4,5,2),(4,8,1);

-- Entradas por compra recebida: o saldo de MATERIAL comeca em zero.
INSERT IGNORE INTO movimentacao_estoque
(id_movimentacao,id_material,id_compra,id_producao,id_funcionario,tipo_movimentacao,quantidade,data_movimentacao,observacao) VALUES
(1,1,1,NULL,4,'ENTRADA',40,'2026-09-04 08:00:00','Compra recebida'),
(2,2,1,NULL,4,'ENTRADA',30,'2026-09-04 08:00:00','Compra recebida'),
(3,4,1,NULL,4,'ENTRADA',18,'2026-09-04 08:00:00','Compra recebida'),
(4,3,2,NULL,4,'ENTRADA',12,'2026-09-09 08:00:00','Compra recebida'),
(5,5,2,NULL,4,'ENTRADA',8,'2026-09-09 08:00:00','Compra recebida'),
(6,6,3,NULL,4,'ENTRADA',5,'2026-09-14 08:00:00','Compra recebida'),
(7,7,3,NULL,4,'ENTRADA',7,'2026-09-14 08:00:00','Compra recebida'),
(8,8,3,NULL,4,'ENTRADA',10,'2026-09-14 08:00:00','Compra recebida');

-- Consumo de producao: cada saida e registrada e diminui o saldo.
INSERT IGNORE INTO movimentacao_estoque
(id_movimentacao,id_material,id_compra,id_producao,id_funcionario,tipo_movimentacao,quantidade,data_movimentacao,observacao) VALUES
(9,1,NULL,1,3,'SAIDA',5,'2026-10-01 09:00:00','Consumo producao 1'),
(10,6,NULL,1,3,'SAIDA',3,'2026-10-01 09:00:00','Consumo producao 1'),
(11,2,NULL,2,5,'SAIDA',4,'2026-10-03 09:00:00','Consumo producao 2'),
(12,3,NULL,2,5,'SAIDA',2,'2026-10-03 09:00:00','Consumo producao 2'),
(13,4,NULL,3,3,'SAIDA',3,'2026-10-07 10:00:00','Consumo producao 3'),
(14,7,NULL,3,3,'SAIDA',2,'2026-10-07 10:00:00','Consumo producao 3'),
(15,5,NULL,4,5,'SAIDA',2,'2026-10-09 10:00:00','Consumo producao 4'),
(16,8,NULL,4,5,'SAIDA',1,'2026-10-09 10:00:00','Consumo producao 4');

-- Somente producoes com materiais podem ser marcadas CONCLUIDA.
UPDATE producao
SET status = 'CONCLUIDA', data_conclusao = '2026-10-01 16:00:00'
WHERE id_producao = 1 AND status = 'EM_ANDAMENTO';
UPDATE producao
SET status = 'CONCLUIDA', data_conclusao = '2026-10-03 17:00:00'
WHERE id_producao = 2 AND status = 'EM_ANDAMENTO';
UPDATE producao
SET status = 'CONCLUIDA', data_conclusao = '2026-10-07 17:00:00'
WHERE id_producao = 3 AND status = 'EM_ANDAMENTO';
UPDATE producao
SET status = 'CONCLUIDA', data_conclusao = '2026-10-09 17:00:00'
WHERE id_producao = 4 AND status = 'EM_ANDAMENTO';

INSERT IGNORE INTO esterilizacao
(id_esterilizacao,id_equipamento,id_funcionario,data_inicio,data_fim,tipo_ciclo,status,observacao) VALUES
(1,1,5,'2026-10-01 07:00:00','2026-10-01 08:00:00','Autoclave 134C','CONCLUIDO','Ciclo aprovado'),
(2,1,5,'2026-10-03 07:00:00','2026-10-03 08:00:00','Autoclave 134C','CONCLUIDO','Ciclo aprovado'),
(3,1,5,'2026-10-04 07:00:00','2026-10-04 08:00:00','Autoclave 134C','FALHA','Indicador quimico nao aprovado'),
(4,1,5,'2026-10-10 07:00:00','2026-10-10 08:00:00','Autoclave 134C','CONCLUIDO','Ciclo aprovado'),
(5,1,5,'2026-10-15 07:00:00','2026-10-15 08:00:00','Autoclave 134C','FALHA','Temperatura abaixo do esperado'),
(6,1,5,'2026-10-20 07:00:00','2026-10-20 08:00:00','Autoclave 134C','CONCLUIDO','Ciclo aprovado');

-- ==================== 4. VIEWS DO DASHBOARD ===========================

CREATE OR REPLACE VIEW vw_dashboard_equipamentos AS
SELECT e.id_equipamento, e.nome_equipamento, e.tipo_equipamento,
       e.numero_serie, e.status, e.proxima_manutencao,
       c.nome_consultorio, f.nome AS responsavel,
       CASE
           WHEN e.status = 'DISPONIVEL' AND NOT EXISTS (
               SELECT 1 FROM manutencao m
               WHERE m.id_equipamento = e.id_equipamento AND m.status = 'ABERTA'
           ) THEN 'DISPONIVEL'
           ELSE 'INDISPONIVEL'
       END AS disponibilidade
FROM equipamento e
JOIN consultorio c ON c.id_consultorio = e.id_consultorio
LEFT JOIN funcionario f ON f.id_funcionario = e.id_funcionario;

CREATE OR REPLACE VIEW vw_dashboard_estoque AS
SELECT m.id_material, m.nome_material, m.categoria, m.unidade_medida,
       m.quantidade_estoque, m.estoque_minimo, m.localizacao, m.status,
       (m.quantidade_estoque * m.valor_unitario_referencia) AS valor_estimado_estoque,
       CASE WHEN m.quantidade_estoque <= m.estoque_minimo
            THEN 'ABAIXO_DO_MINIMO' ELSE 'REGULAR' END AS situacao_estoque
FROM material m;

CREATE OR REPLACE VIEW vw_dashboard_financeiro AS
SELECT pg.id_pagamento, pg.id_atendimento, a.id_paciente,
       pc.nome AS paciente, pg.data_pagamento, pg.valor,
       pg.forma_pagamento, pg.status,
       CASE WHEN pg.status = 'PAGO' THEN pg.valor ELSE 0.00 END AS valor_recebido
FROM pagamento pg
JOIN atendimento a ON a.id_atendimento = pg.id_atendimento
JOIN paciente pc ON pc.id_paciente = a.id_paciente;

CREATE OR REPLACE VIEW vw_dashboard_agenda AS
SELECT ag.id_agendamento, ag.data_hora, ag.status,
       ag.id_paciente, pc.nome AS paciente,
       ag.id_funcionario, f.nome AS funcionario,
       ag.id_consultorio, c.nome_consultorio,
       CASE WHEN ag.status = 'CANCELADO' THEN 1 ELSE 0 END AS cancelado
FROM agendamento ag
JOIN paciente pc ON pc.id_paciente = ag.id_paciente
JOIN funcionario f ON f.id_funcionario = ag.id_funcionario
JOIN consultorio c ON c.id_consultorio = ag.id_consultorio;

CREATE OR REPLACE VIEW vw_dashboard_manutencao AS
SELECT m.id_manutencao, m.id_equipamento, e.nome_equipamento,
       m.id_funcionario, f.nome AS responsavel,
       m.tipo_manutencao, m.data_inicio, m.data_conclusao,
       m.custo, m.status, m.descricao
FROM manutencao m
JOIN equipamento e ON e.id_equipamento = m.id_equipamento
JOIN funcionario f ON f.id_funcionario = m.id_funcionario;

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

-- ==================== 7. CONFERENCIA FINAL =============================
SELECT 'Banco odontologia_sasaki criado/selecionado' AS resultado;
SELECT COUNT(*) AS total_tabelas
FROM information_schema.tables
WHERE table_schema = 'odontologia_sasaki' AND table_type = 'BASE TABLE';
SELECT COUNT(*) AS total_views
FROM information_schema.views
WHERE table_schema = 'odontologia_sasaki';
SELECT id_material, nome_material, quantidade_estoque, estoque_minimo
FROM material ORDER BY id_material;
