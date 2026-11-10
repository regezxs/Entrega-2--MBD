-- Odontologia Sasaki — MySQL 8.0.16+ | estrutura + dados fictícios da planilha
-- Baseado no DER atualizado e na planilha; mantém os nomes originais das colunas.
-- Cria ou reutiliza o schema. Na carga, chaves duplicadas preservam a linha existente.
-- Use um schema vazio se precisar reproduzir exatamente os dados fictícios.
CREATE DATABASE IF NOT EXISTS `odontologia_sasaki_atualizado` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `odontologia_sasaki_atualizado`;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `consultorio` (
  `id_consultorio` BIGINT NOT NULL AUTO_INCREMENT,
  `nome_consultorio` VARCHAR(180) NOT NULL,
  `numero_sala` VARCHAR(20) NOT NULL,
  `andar` INT NULL,
  `status` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_consultorio`),
  UNIQUE KEY `uq_consultorio_registro` (`andar`, `numero_sala`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `funcionario` (
  `id_funcionario` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(180) NOT NULL,
  `cpf` VARCHAR(14) NULL,
  `cargo` VARCHAR(120) NULL,
  `telefone` VARCHAR(120) NULL,
  `email` VARCHAR(150) NULL,
  `data_admissao` DATE NOT NULL,
  `situacao_profissional` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_funcionario`),
  UNIQUE KEY `uq_funcionario_registro` (`cpf`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `paciente` (
  `id_paciente` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(180) NOT NULL,
  `cpf` VARCHAR(14) NULL,
  `data_nascimento` DATE NULL,
  `telefone` VARCHAR(120) NULL,
  `email` VARCHAR(150) NULL,
  `endereco` VARCHAR(250) NULL,
  `convenio` VARCHAR(120) NULL,
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `uq_paciente_registro` (`cpf`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `fornecedor` (
  `id_fornecedor` BIGINT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(180) NOT NULL,
  `cnpj` VARCHAR(18) NULL,
  `telefone` VARCHAR(120) NULL,
  `email` VARCHAR(150) NULL,
  `endereco` VARCHAR(250) NULL,
  `status` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_fornecedor`),
  UNIQUE KEY `uq_fornecedor_registro` (`cnpj`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `material` (
  `id_material` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(180) NOT NULL,
  `categoria` VARCHAR(120) NOT NULL,
  `descricao` TEXT NULL,
  `quantidade_estoque` INT NULL,
  `estoque_minimo` INT NULL,
  `valor` DECIMAL(12,2) NOT NULL,
  `validade` DATE NULL,
  `localizacao` VARCHAR(120) NULL,
  `situacao_estoque` VARCHAR(120) NULL,
  PRIMARY KEY (`id_material`),
  CONSTRAINT `ck_material_quantidade_estoque_positivo` CHECK (`quantidade_estoque` >= 0),
  CONSTRAINT `ck_material_estoque_minimo_positivo` CHECK (`estoque_minimo` >= 0),
  CONSTRAINT `ck_material_valor_positivo` CHECK (`valor` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `procedimento` (
  `id_procedimento` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(180) NOT NULL,
  `descricao` TEXT NULL,
  `preco` DECIMAL(12,2) NOT NULL,
  `duracao_estimada_min` INT NULL,
  PRIMARY KEY (`id_procedimento`),
  CONSTRAINT `ck_procedimento_preco_positivo` CHECK (`preco` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `equipamento` (
  `id_equipamento` BIGINT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(180) NOT NULL,
  `tipo` VARCHAR(120) NOT NULL,
  `numero_serie` VARCHAR(120) NULL,
  `id_consultorio` BIGINT NOT NULL,
  `id_responsavel` BIGINT NOT NULL,
  `data_aquisicao` DATE NULL,
  `ultima_manutencao` DATE NULL,
  `status` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_equipamento`),
  UNIQUE KEY `uq_equipamento_registro` (`numero_serie`),
  CONSTRAINT `fk_equipamento_id_consultorio` FOREIGN KEY (`id_consultorio`) REFERENCES `consultorio` (`id_consultorio`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_equipamento_id_responsavel` FOREIGN KEY (`id_responsavel`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `manutencao` (
  `id_manutencao` BIGINT NOT NULL AUTO_INCREMENT,
  `id_equipamento` BIGINT NOT NULL,
  `tecnico_responsavel` VARCHAR(180) NULL,
  `tipo_manutencao` VARCHAR(120) NOT NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NULL,
  `descricao` TEXT NULL,
  `custo` DECIMAL(12,2) NULL,
  `status` VARCHAR(120) NOT NULL,
  `id_funcionario` BIGINT NULL,
  PRIMARY KEY (`id_manutencao`),
  CONSTRAINT `fk_manutencao_id_equipamento` FOREIGN KEY (`id_equipamento`) REFERENCES `equipamento` (`id_equipamento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_manutencao_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_manutencao_custo_positivo` CHECK (`custo` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `agendamento` (
  `id_agendamento` BIGINT NOT NULL AUTO_INCREMENT,
  `id_paciente` BIGINT NOT NULL,
  `id_funcionario` BIGINT NOT NULL,
  `id_consultorio` BIGINT NOT NULL,
  `data` DATE NOT NULL,
  `horario` TIME NULL,
  `situacao` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_agendamento`),
  CONSTRAINT `fk_agendamento_id_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_agendamento_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_agendamento_id_consultorio` FOREIGN KEY (`id_consultorio`) REFERENCES `consultorio` (`id_consultorio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `atendimento` (
  `id_atendimento` BIGINT NOT NULL AUTO_INCREMENT,
  `id_paciente` BIGINT NOT NULL,
  `id_profissional` BIGINT NOT NULL,
  `id_consultorio` BIGINT NOT NULL,
  `data` DATE NOT NULL,
  `descricao` TEXT NULL,
  `status` VARCHAR(120) NOT NULL,
  `id_agendamento` BIGINT NULL,
  PRIMARY KEY (`id_atendimento`),
  CONSTRAINT `fk_atendimento_id_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `agendamento` (`id_agendamento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_atendimento_id_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_atendimento_id_profissional` FOREIGN KEY (`id_profissional`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_atendimento_id_consultorio` FOREIGN KEY (`id_consultorio`) REFERENCES `consultorio` (`id_consultorio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `atendimento_procedimento` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `id_atendimento` BIGINT NOT NULL,
  `id_procedimento` BIGINT NOT NULL,
  `quantidade` INT NOT NULL,
  `valor_cobrado` DECIMAL(12,2) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_atendimento_procedimento_id_atendimento` FOREIGN KEY (`id_atendimento`) REFERENCES `atendimento` (`id_atendimento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_atendimento_procedimento_id_procedimento` FOREIGN KEY (`id_procedimento`) REFERENCES `procedimento` (`id_procedimento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_atendimento_procedimento_quantidade_positivo` CHECK (`quantidade` >= 0),
  CONSTRAINT `ck_atendimento_procedimento_valor_cobrado_positivo` CHECK (`valor_cobrado` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `plano_tratamento` (
  `id_plano` BIGINT NOT NULL AUTO_INCREMENT,
  `id_paciente` BIGINT NOT NULL,
  `id_profissional` BIGINT NOT NULL,
  `descricao` TEXT NULL,
  `data_inicio` DATE NOT NULL,
  `data_prevista_fim` DATE NULL,
  `situacao` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_plano`),
  CONSTRAINT `fk_plano_tratamento_id_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_plano_tratamento_id_profissional` FOREIGN KEY (`id_profissional`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `plano_procedimento` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `id_plano` BIGINT NOT NULL,
  `id_procedimento` BIGINT NOT NULL,
  `quantidade` INT NOT NULL,
  `valor_previsto` DECIMAL(12,2) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_plano_procedimento_id_plano` FOREIGN KEY (`id_plano`) REFERENCES `plano_tratamento` (`id_plano`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_plano_procedimento_id_procedimento` FOREIGN KEY (`id_procedimento`) REFERENCES `procedimento` (`id_procedimento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_plano_procedimento_quantidade_positivo` CHECK (`quantidade` >= 0),
  CONSTRAINT `ck_plano_procedimento_valor_previsto_positivo` CHECK (`valor_previsto` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `pagamento` (
  `id_pagamento` BIGINT NOT NULL AUTO_INCREMENT,
  `id_atendimento` BIGINT NOT NULL,
  `valor` DECIMAL(12,2) NOT NULL,
  `data_pagamento` DATE NULL,
  `forma_pagamento` VARCHAR(120) NULL,
  `situacao_financeira` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_pagamento`),
  CONSTRAINT `fk_pagamento_id_atendimento` FOREIGN KEY (`id_atendimento`) REFERENCES `atendimento` (`id_atendimento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_pagamento_valor_positivo` CHECK (`valor` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `compra` (
  `id_compra` BIGINT NOT NULL AUTO_INCREMENT,
  `id_fornecedor` BIGINT NOT NULL,
  `id_funcionario` BIGINT NOT NULL,
  `data_compra` DATE NOT NULL,
  `data_recebimento` DATE NULL,
  `situacao` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_compra`),
  CONSTRAINT `fk_compra_id_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id_fornecedor`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_compra_id_funcionario` FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `item_compra` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `id_compra` BIGINT NOT NULL,
  `id_material` BIGINT NOT NULL,
  `quantidade` INT NOT NULL,
  `valor_unitario` DECIMAL(12,2) NOT NULL,
  `valor_total` DECIMAL(12,2) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_item_compra_id_compra` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_item_compra_id_material` FOREIGN KEY (`id_material`) REFERENCES `material` (`id_material`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_item_compra_quantidade_positivo` CHECK (`quantidade` >= 0),
  CONSTRAINT `ck_item_compra_valor_unitario_positivo` CHECK (`valor_unitario` >= 0),
  CONSTRAINT `ck_item_compra_valor_total_positivo` CHECK (`valor_total` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `producao` (
  `id_producao` BIGINT NOT NULL AUTO_INCREMENT,
  `tipo_producao` VARCHAR(180) NOT NULL,
  `id_responsavel` BIGINT NOT NULL,
  `quantidade` INT NOT NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NULL,
  `status` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`id_producao`),
  CONSTRAINT `fk_producao_id_responsavel` FOREIGN KEY (`id_responsavel`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_producao_quantidade_positivo` CHECK (`quantidade` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `item_producao` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `id_producao` BIGINT NOT NULL,
  `id_material` BIGINT NOT NULL,
  `quantidade_consumida` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_item_producao_id_producao` FOREIGN KEY (`id_producao`) REFERENCES `producao` (`id_producao`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_item_producao_id_material` FOREIGN KEY (`id_material`) REFERENCES `material` (`id_material`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_item_producao_quantidade_consumida_positivo` CHECK (`quantidade_consumida` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `movimentacao_estoque` (
  `id_movimentacao` BIGINT NOT NULL AUTO_INCREMENT,
  `id_material` BIGINT NOT NULL,
  `tipo` VARCHAR(120) NOT NULL,
  `quantidade` INT NOT NULL,
  `data` DATE NOT NULL,
  `id_responsavel` BIGINT NOT NULL,
  `origem` VARCHAR(120) NULL,
  `id_compra` BIGINT NULL,
  `id_producao` BIGINT NULL,
  PRIMARY KEY (`id_movimentacao`),
  CONSTRAINT `fk_movimentacao_estoque_id_material` FOREIGN KEY (`id_material`) REFERENCES `material` (`id_material`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_id_responsavel` FOREIGN KEY (`id_responsavel`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_id_compra` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_id_producao` FOREIGN KEY (`id_producao`) REFERENCES `producao` (`id_producao`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_movimentacao_estoque_quantidade_positivo` CHECK (`quantidade` >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `esterilizacao` (
  `id_ciclo` BIGINT NOT NULL AUTO_INCREMENT,
  `id_equipamento` BIGINT NOT NULL,
  `id_responsavel` BIGINT NOT NULL,
  `inicio_ciclo` DATETIME NOT NULL,
  `fim_ciclo` DATETIME NULL,
  `tipo` VARCHAR(120) NOT NULL,
  `resultado` VARCHAR(120) NULL,
  `observacoes` TEXT NULL,
  PRIMARY KEY (`id_ciclo`),
  CONSTRAINT `fk_esterilizacao_id_equipamento` FOREIGN KEY (`id_equipamento`) REFERENCES `equipamento` (`id_equipamento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_esterilizacao_id_responsavel` FOREIGN KEY (`id_responsavel`) REFERENCES `funcionario` (`id_funcionario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

START TRANSACTION;

-- Dados das abas da planilha (identificadores preservados; informações fictícias).
-- consultorio (6 registros)
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (1, 'Consultório Clínico 1', 101, 1, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (2, 'Consultório Clínico 2', 102, 1, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (3, 'Consultório Ortodontia', 201, 2, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (4, 'Sala de Radiologia', 202, 2, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (5, 'Laboratório de Prótese', 203, 2, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;
INSERT INTO `consultorio` (`id_consultorio`, `nome_consultorio`, `numero_sala`, `andar`, `status`) VALUES (6, 'Central de Esterilização', 103, 1, 'Ativo') ON DUPLICATE KEY UPDATE `id_consultorio` = `id_consultorio`;

-- funcionario (10 registros)
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (1, 'Dra. Helena Sasaki', '111.111.111-01', 'Dentista', '(11) 98888-0001', 'helena@clinica.teste', '2018-03-01', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (2, 'Dr. Ricardo Tanaka', '111.111.111-02', 'Dentista', '(11) 98888-0002', 'ricardo@clinica.teste', '2019-08-15', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (3, 'Dra. Paula Yamamoto', '111.111.111-03', 'Ortodontista', '(11) 98888-0003', 'paula@clinica.teste', '2021-02-10', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (4, 'Marcos Vieira', '111.111.111-04', 'Técnico em Prótese', '(11) 98888-0004', 'marcos@clinica.teste', '2020-05-04', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (5, 'Sandra Lopes', '111.111.111-05', 'Auxiliar de Saúde Bucal', '(11) 98888-0005', 'sandra@clinica.teste', '2022-01-17', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (6, 'Tiago Ramos', '111.111.111-06', 'Auxiliar de Saúde Bucal', '(11) 98888-0006', 'tiago@clinica.teste', '2023-06-05', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (7, 'Clara Mota', '111.111.111-07', 'Recepcionista', '(11) 98888-0007', 'clara@clinica.teste', '2022-09-12', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (8, 'Eduardo Prado', '111.111.111-08', 'Gerente Administrativo', '(11) 98888-0008', 'eduardo@clinica.teste', '2018-03-01', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (9, 'Natália Freitas', '111.111.111-09', 'Responsável pela Esterilização', '(11) 98888-0009', 'natalia@clinica.teste', '2021-11-03', 'Ativo') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;
INSERT INTO `funcionario` (`id_funcionario`, `nome`, `cpf`, `cargo`, `telefone`, `email`, `data_admissao`, `situacao_profissional`) VALUES (10, 'Roberto Dias', '111.111.111-10', 'Dentista', '(11) 98888-0010', 'roberto@clinica.teste', '2020-01-20', 'Afastado') ON DUPLICATE KEY UPDATE `id_funcionario` = `id_funcionario`;

-- paciente (20 registros)
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (1, 'Ana Beatriz Lima', '107.203.305-01', '1977-01-24', '(11) 95506-5012', 'ana1@email.teste', 'Av. Brasil, 152 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (2, 'Carlos Eduardo Souza', '114.206.310-02', '2004-02-19', '(11) 97912-1520', 'carlos2@email.teste', 'Rua das Acácias, 105 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (3, 'Fernanda Oliveira', '121.209.315-03', '1984-09-20', '(11) 91434-4257', 'fernanda3@email.teste', 'Rua dos Ipês, 675 - São Paulo/SP', 'DentalVida (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (4, 'João Pedro Martins', '128.212.320-04', '1996-04-15', '(11) 95557-1106', 'joão4@email.teste', 'Av. Brasil, 724 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (5, 'Mariana Costa', '135.215.325-05', '1991-05-05', '(11) 94527-6514', 'mariana5@email.teste', 'Rua das Acácias, 104 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (6, 'Rafael Almeida', '142.218.330-06', '1976-06-28', '(11) 96635-5333', 'rafael6@email.teste', 'Rua das Acácias, 757 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (7, 'Juliana Rocha', '149.221.335-07', '2004-02-13', '(11) 92291-5803', 'juliana7@email.teste', 'Rua dos Ipês, 643 - São Paulo/SP', 'SorriSaúde (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (8, 'Lucas Ferreira', '156.224.340-08', '1982-12-03', '(11) 91750-4733', 'lucas8@email.teste', 'Rua do Sol, 91 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (9, 'Camila Ribeiro', '163.227.345-09', '1976-07-09', '(11) 98428-6977', 'camila9@email.teste', 'Av. Brasil, 389 - São Paulo/SP', 'SorriSaúde (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (10, 'Gabriel Nunes', '170.230.350-10', '1983-11-09', '(11) 92169-3803', 'gabriel10@email.teste', 'Av. Paulista Nova, 756 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (11, 'Patrícia Mendes', '177.233.355-11', '1980-08-13', '(11) 95422-4598', 'patrícia11@email.teste', 'Rua dos Ipês, 342 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (12, 'Thiago Barbosa', '184.236.360-12', '1984-01-26', '(11) 96168-7572', 'thiago12@email.teste', 'Rua do Sol, 77 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (13, 'Larissa Pinto', '191.239.365-13', '1990-04-21', '(11) 99179-7482', 'larissa13@email.teste', 'Rua dos Ipês, 479 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (14, 'Bruno Carvalho', '198.242.370-14', '1986-03-08', '(11) 99830-5304', 'bruno14@email.teste', 'Rua dos Ipês, 608 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (15, 'Aline Teixeira', '205.245.375-15', '1995-06-08', '(11) 93266-9348', 'aline15@email.teste', 'Rua Esperança, 103 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (16, 'Diego Moreira', '212.248.380-16', '1977-03-21', '(11) 93621-7916', 'diego16@email.teste', 'Av. Paulista Nova, 75 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (17, 'Renata Cardoso', '219.251.385-17', '1994-10-15', '(11) 99669-5119', 'renata17@email.teste', 'Av. Paulista Nova, 891 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (18, 'Felipe Araújo', '226.254.390-18', '1977-11-18', '(11) 95371-6573', 'felipe18@email.teste', 'Rua das Acácias, 310 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (19, 'Vanessa Duarte', '233.257.395-19', '1980-08-01', '(11) 95315-9201', 'vanessa19@email.teste', 'Av. Brasil, 529 - São Paulo/SP', 'Particular') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;
INSERT INTO `paciente` (`id_paciente`, `nome`, `cpf`, `data_nascimento`, `telefone`, `email`, `endereco`, `convenio`) VALUES (20, 'Marcelo Batista', '240.260.400-20', '1989-11-17', '(11) 94258-3504', 'marcelo20@email.teste', 'Rua do Sol, 790 - São Paulo/SP', 'OdontoPlus (fictício)') ON DUPLICATE KEY UPDATE `id_paciente` = `id_paciente`;

-- fornecedor (5 registros)
INSERT INTO `fornecedor` (`id_fornecedor`, `razao_social`, `cnpj`, `telefone`, `email`, `endereco`, `status`) VALUES (1, 'DentalMax Suprimentos Ltda (fictícia)', '11.111.111/0001-01', '(11) 3000-0001', 'vendas@dentalmax.teste', 'Rua Industrial, 100 - São Paulo/SP', 'Ativo') ON DUPLICATE KEY UPDATE `id_fornecedor` = `id_fornecedor`;
INSERT INTO `fornecedor` (`id_fornecedor`, `razao_social`, `cnpj`, `telefone`, `email`, `endereco`, `status`) VALUES (2, 'OdontoPro Materiais Ltda (fictícia)', '22.222.222/0001-02', '(11) 3000-0002', 'contato@odontopro.teste', 'Av. Comercial, 250 - Guarulhos/SP', 'Ativo') ON DUPLICATE KEY UPDATE `id_fornecedor` = `id_fornecedor`;
INSERT INTO `fornecedor` (`id_fornecedor`, `razao_social`, `cnpj`, `telefone`, `email`, `endereco`, `status`) VALUES (3, 'SorrisoTech Equipamentos S.A. (fictícia)', '33.333.333/0001-03', '(11) 3000-0003', 'comercial@sorrisotech.teste', 'Rua da Tecnologia, 45 - Campinas/SP', 'Ativo') ON DUPLICATE KEY UPDATE `id_fornecedor` = `id_fornecedor`;
INSERT INTO `fornecedor` (`id_fornecedor`, `razao_social`, `cnpj`, `telefone`, `email`, `endereco`, `status`) VALUES (4, 'BioEsteril Distribuidora Ltda (fictícia)', '44.444.444/0001-04', '(11) 3000-0004', 'pedidos@bioesteril.teste', 'Rua Higiene, 78 - Osasco/SP', 'Ativo') ON DUPLICATE KEY UPDATE `id_fornecedor` = `id_fornecedor`;
INSERT INTO `fornecedor` (`id_fornecedor`, `razao_social`, `cnpj`, `telefone`, `email`, `endereco`, `status`) VALUES (5, 'ProtLab Insumos Ltda (fictícia)', '55.555.555/0001-05', '(11) 3000-0005', 'vendas@protlab.teste', 'Rua do Laboratório, 12 - Santo André/SP', 'Inativo') ON DUPLICATE KEY UPDATE `id_fornecedor` = `id_fornecedor`;

-- material (15 registros)
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (1, 'Luva de procedimento M (cx 100)', 'Descartáveis', 'Luvas de látex', 12, 15, 32.9, '2027-06-30', 'Armário A1', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (2, 'Máscara cirúrgica (cx 50)', 'Descartáveis', 'Máscara tripla camada', 20, 10, 18.5, '2027-03-31', 'Armário A1', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (3, 'Anestésico Lidocaína 2% (cx 50)', 'Anestésicos', 'Tubetes 1,8 ml', 8, 8, 95, '2027-01-31', 'Geladeira B', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (4, 'Resina composta A2', 'Restauradores', 'Seringa 4 g', 6, 5, 78, '2027-09-30', 'Armário B2', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (5, 'Ácido fosfórico 37%', 'Restauradores', 'Seringa 3 ml', 4, 6, 14, '2027-04-30', 'Armário B2', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (6, 'Cimento de ionômero de vidro', 'Restauradores', 'Kit pó e líquido', 3, 3, 64, '2027-08-31', 'Armário B2', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (7, 'Fio de sutura 4-0', 'Cirúrgicos', 'Caixa com 24 unidades', 9, 5, 52, '2028-02-28', 'Armário C1', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (8, 'Gaze estéril (pct 500)', 'Descartáveis', 'Pacote com 500 unidades', 25, 10, 22, '2028-01-31', 'Armário A2', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (9, 'Gesso especial tipo IV (kg)', 'Prótese', 'Gesso para modelos', 7, 4, 29.9, '2028-05-31', 'Laboratório', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (10, 'Resina acrílica incolor', 'Prótese', 'Kit pó e líquido', 2, 3, 85, '2027-10-31', 'Laboratório', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (11, 'Dente de estoque (jogo)', 'Prótese', 'Jogo de 28 dentes', 5, 4, 120, '2029-01-31', 'Laboratório', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (12, 'Envelope para esterilização', 'Esterilização', 'Caixa 200 un.', 14, 6, 45, '2028-06-30', 'Central', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (13, 'Indicador biológico', 'Esterilização', 'Caixa 25 ampolas', 3, 3, 110, '2027-02-28', 'Central', 'Mínimo ou abaixo') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (14, 'Fio dental profissional', 'Higiene', 'Rolo 100 m', 11, 5, 9.9, '2028-09-30', 'Armário A3', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;
INSERT INTO `material` (`id_material`, `nome`, `categoria`, `descricao`, `quantidade_estoque`, `estoque_minimo`, `valor`, `validade`, `localizacao`, `situacao_estoque`) VALUES (15, 'Fluoreto gel 2%', 'Preventivos', 'Frasco 200 ml', 5, 4, 24, '2027-07-31', 'Armário B1', 'OK') ON DUPLICATE KEY UPDATE `id_material` = `id_material`;

-- procedimento (10 registros)
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (1, 'Consulta de avaliação', 'Exame clínico inicial', 120, 30) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (2, 'Limpeza (profilaxia)', 'Remoção de tártaro e polimento', 180, 45) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (3, 'Restauração em resina', 'Restauração dentária', 250, 60) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (4, 'Extração simples', 'Remoção de dente', 300, 40) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (5, 'Tratamento de canal', 'Endodontia', 800, 90) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (6, 'Clareamento dental', 'Clareamento em consultório', 900, 60) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (7, 'Raio-X periapical', 'Radiografia', 60, 15) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (8, 'Aplicação de flúor', 'Prevenção', 70, 20) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (9, 'Manutenção ortodôntica', 'Ajuste de aparelho', 160, 30) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;
INSERT INTO `procedimento` (`id_procedimento`, `nome`, `descricao`, `preco`, `duracao_estimada_min`) VALUES (10, 'Prótese total', 'Confecção e instalação', 2200, 120) ON DUPLICATE KEY UPDATE `id_procedimento` = `id_procedimento`;

-- equipamento (10 registros)
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (1, 'Cadeira Odontológica Aurora', 'Cadeira', 'SN-CAD-1001', 1, 1, '2019-02-10', '2026-06-12', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (2, 'Cadeira Odontológica Aurora II', 'Cadeira', 'SN-CAD-1002', 2, 2, '2020-07-03', '2026-09-02', 'Em manutenção') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (3, 'Cadeira Ortodôntica Delta', 'Cadeira', 'SN-CAD-1003', 3, 3, '2021-03-18', '2026-05-20', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (4, 'Autoclave Vapor 21L', 'Esterilização', 'SN-AUT-2001', 6, 9, '2020-01-15', '2026-08-05', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (5, 'Autoclave Vapor 12L', 'Esterilização', 'SN-AUT-2002', 6, 9, '2022-04-22', '2026-10-06', 'Em manutenção') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (6, 'Raio-X Periapical Lumina', 'Radiologia', 'SN-RX-3001', 4, 2, '2021-09-01', '2026-04-14', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (7, 'Fotopolimerizador LED Sol', 'Instrumental', 'SN-FOT-4001', 1, 1, '2023-02-08', NULL, 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (8, 'Compressor Odontológico Silent', 'Infraestrutura', 'SN-CMP-5001', 6, 8, '2019-02-10', '2026-07-25', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (9, 'Ultrassom Profilático Clean', 'Instrumental', 'SN-ULT-6001', 2, 6, '2022-11-30', '2026-03-09', 'Inativo') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;
INSERT INTO `equipamento` (`id_equipamento`, `nome`, `tipo`, `numero_serie`, `id_consultorio`, `id_responsavel`, `data_aquisicao`, `ultima_manutencao`, `status`) VALUES (10, 'Motor de Bancada para Prótese', 'Prótese', 'SN-MTB-7001', 5, 4, '2020-08-12', '2026-06-30', 'Em operação') ON DUPLICATE KEY UPDATE `id_equipamento` = `id_equipamento`;

-- manutencao (10 registros)
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (1, 1, 'Oficina TecnoDent (fictícia)', 'Preventiva', '2026-06-10', '2026-06-12', 'Revisão geral e lubrificação', 350, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (2, 3, 'Oficina TecnoDent (fictícia)', 'Preventiva', '2026-05-19', '2026-05-20', 'Revisão do sistema hidráulico', 280, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (3, 4, 'Assistência VaporMed (fictícia)', 'Corretiva', '2026-08-03', '2026-08-05', 'Troca de resistência', 620, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (4, 6, 'RadioService (fictícia)', 'Preventiva', '2026-04-13', '2026-04-14', 'Calibração do cabeçote', 450, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (5, 8, 'Oficina TecnoDent (fictícia)', 'Corretiva', '2026-07-24', '2026-07-25', 'Troca de filtro e válvula', 390, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (6, 2, 'Oficina TecnoDent (fictícia)', 'Corretiva', '2026-09-02', NULL, 'Falha no pedal de acionamento', 0, 'Em andamento', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (7, 5, 'Assistência VaporMed (fictícia)', 'Corretiva', '2026-10-06', NULL, 'Vazamento na câmara', 0, 'Em andamento', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (8, 10, 'Oficina TecnoDent (fictícia)', 'Preventiva', '2026-06-29', '2026-06-30', 'Troca de escovas do motor', 180, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (9, 1, 'Oficina TecnoDent (fictícia)', 'Corretiva', '2026-09-14', '2026-09-16', 'Troca de mangueira de ar', 210, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;
INSERT INTO `manutencao` (`id_manutencao`, `id_equipamento`, `tecnico_responsavel`, `tipo_manutencao`, `data_inicio`, `data_fim`, `descricao`, `custo`, `status`, `id_funcionario`) VALUES (10, 4, 'Assistência VaporMed (fictícia)', 'Preventiva', '2026-10-20', '2026-10-21', 'Revisão semestral', 300, 'Concluída', NULL) ON DUPLICATE KEY UPDATE `id_manutencao` = `id_manutencao`;

-- agendamento (70 registros)
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (1, 17, 1, 2, '2026-07-01', '17:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (2, 12, 2, 1, '2026-07-02', '08:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (3, 5, 3, 3, '2026-07-06', '17:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (4, 10, 2, 2, '2026-07-06', '17:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (5, 19, 3, 3, '2026-07-07', '11:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (6, 3, 1, 2, '2026-07-09', '09:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (7, 19, 2, 1, '2026-07-13', '17:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (8, 4, 1, 2, '2026-07-13', '15:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (9, 2, 2, 2, '2026-07-14', '09:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (10, 6, 2, 2, '2026-07-16', '11:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (11, 3, 1, 1, '2026-07-20', '16:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (12, 1, 2, 2, '2026-07-20', '17:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (13, 2, 3, 3, '2026-07-21', '08:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (14, 6, 1, 1, '2026-07-23', '10:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (15, 3, 3, 3, '2026-07-27', '11:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (16, 19, 1, 1, '2026-07-27', '09:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (17, 8, 2, 2, '2026-07-28', '10:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (18, 4, 1, 1, '2026-07-30', '14:00:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (19, 3, 1, 2, '2026-08-03', '14:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (20, 1, 3, 3, '2026-08-03', '14:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (21, 9, 1, 1, '2026-08-04', '10:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (22, 17, 2, 2, '2026-08-06', '08:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (23, 6, 3, 3, '2026-08-10', '17:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (24, 18, 1, 2, '2026-08-10', '10:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (25, 7, 3, 3, '2026-08-11', '11:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (26, 8, 1, 1, '2026-08-13', '16:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (27, 9, 1, 1, '2026-08-14', '16:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (28, 8, 1, 1, '2026-08-17', '16:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (29, 18, 2, 1, '2026-08-18', '09:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (30, 14, 2, 2, '2026-08-20', '16:00:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (31, 19, 1, 2, '2026-08-21', '08:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (32, 12, 2, 1, '2026-08-24', '15:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (33, 11, 2, 2, '2026-08-25', '10:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (34, 18, 1, 2, '2026-08-27', '14:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (35, 16, 3, 3, '2026-08-28', '10:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (36, 17, 3, 3, '2026-08-31', '15:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (37, 1, 1, 1, '2026-09-01', '17:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (38, 13, 1, 1, '2026-09-02', '08:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (39, 8, 1, 2, '2026-09-04', '08:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (40, 18, 3, 3, '2026-09-07', '15:30:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (41, 17, 2, 2, '2026-09-08', '10:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (42, 9, 1, 2, '2026-09-09', '17:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (43, 15, 1, 2, '2026-09-11', '11:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (44, 13, 3, 3, '2026-09-14', '10:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (45, 14, 1, 1, '2026-09-15', '16:30:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (46, 1, 3, 3, '2026-09-16', '16:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (47, 12, 2, 2, '2026-09-18', '16:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (48, 11, 3, 3, '2026-09-21', '16:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (49, 19, 3, 3, '2026-09-21', '08:00:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (50, 5, 2, 1, '2026-09-23', '08:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (51, 9, 2, 2, '2026-09-25', '09:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (52, 3, 3, 3, '2026-09-28', '08:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (53, 8, 1, 2, '2026-09-28', '09:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (54, 6, 2, 1, '2026-09-30', '08:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (55, 4, 3, 3, '2026-10-02', '14:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (56, 11, 1, 2, '2026-10-05', '17:00:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (57, 12, 3, 3, '2026-10-05', '17:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (58, 18, 2, 2, '2026-10-07', '16:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (59, 8, 1, 2, '2026-10-09', '17:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (60, 16, 1, 2, '2026-10-12', '14:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (61, 8, 3, 3, '2026-10-12', '16:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (62, 10, 1, 2, '2026-10-14', '11:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (63, 15, 2, 2, '2026-10-16', '14:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (64, 6, 1, 1, '2026-10-19', '17:30:00', 'Cancelado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (65, 17, 3, 3, '2026-10-19', '14:00:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (66, 10, 1, 2, '2026-10-21', '10:30:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (67, 18, 2, 1, '2026-10-23', '17:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (68, 2, 2, 2, '2026-10-26', '09:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (69, 5, 1, 2, '2026-10-26', '09:00:00', 'Realizado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;
INSERT INTO `agendamento` (`id_agendamento`, `id_paciente`, `id_funcionario`, `id_consultorio`, `data`, `horario`, `situacao`) VALUES (70, 20, 1, 2, '2026-10-28', '17:30:00', 'Agendado') ON DUPLICATE KEY UPDATE `id_agendamento` = `id_agendamento`;

-- atendimento (50 registros)
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (1, 12, 2, 1, '2026-07-02', 'Atendimento do agendamento 2', 'Concluído', 2) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (2, 5, 3, 3, '2026-07-06', 'Atendimento do agendamento 3', 'Concluído', 3) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (3, 10, 2, 2, '2026-07-06', 'Atendimento do agendamento 4', 'Concluído', 4) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (4, 19, 3, 3, '2026-07-07', 'Atendimento do agendamento 5', 'Concluído', 5) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (5, 3, 1, 2, '2026-07-09', 'Atendimento do agendamento 6', 'Concluído', 6) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (6, 4, 1, 2, '2026-07-13', 'Atendimento do agendamento 8', 'Concluído', 8) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (7, 2, 2, 2, '2026-07-14', 'Atendimento do agendamento 9', 'Concluído', 9) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (8, 6, 2, 2, '2026-07-16', 'Atendimento do agendamento 10', 'Concluído', 10) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (9, 3, 1, 1, '2026-07-20', 'Atendimento do agendamento 11', 'Concluído', 11) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (10, 1, 2, 2, '2026-07-20', 'Atendimento do agendamento 12', 'Concluído', 12) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (11, 2, 3, 3, '2026-07-21', 'Atendimento do agendamento 13', 'Concluído', 13) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (12, 19, 1, 1, '2026-07-27', 'Atendimento do agendamento 16', 'Concluído', 16) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (13, 8, 2, 2, '2026-07-28', 'Atendimento do agendamento 17', 'Concluído', 17) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (14, 3, 1, 2, '2026-08-03', 'Atendimento do agendamento 19', 'Concluído', 19) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (15, 9, 1, 1, '2026-08-04', 'Atendimento do agendamento 21', 'Concluído', 21) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (16, 17, 2, 2, '2026-08-06', 'Atendimento do agendamento 22', 'Concluído', 22) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (17, 6, 3, 3, '2026-08-10', 'Atendimento do agendamento 23', 'Concluído', 23) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (18, 18, 1, 2, '2026-08-10', 'Atendimento do agendamento 24', 'Concluído', 24) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (19, 7, 3, 3, '2026-08-11', 'Atendimento do agendamento 25', 'Concluído', 25) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (20, 8, 1, 1, '2026-08-13', 'Atendimento do agendamento 26', 'Concluído', 26) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (21, 9, 1, 1, '2026-08-14', 'Atendimento do agendamento 27', 'Concluído', 27) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (22, 8, 1, 1, '2026-08-17', 'Atendimento do agendamento 28', 'Concluído', 28) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (23, 18, 2, 1, '2026-08-18', 'Atendimento do agendamento 29', 'Concluído', 29) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (24, 19, 1, 2, '2026-08-21', 'Atendimento do agendamento 31', 'Concluído', 31) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (25, 12, 2, 1, '2026-08-24', 'Atendimento do agendamento 32', 'Concluído', 32) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (26, 11, 2, 2, '2026-08-25', 'Atendimento do agendamento 33', 'Concluído', 33) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (27, 18, 1, 2, '2026-08-27', 'Atendimento do agendamento 34', 'Concluído', 34) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (28, 17, 3, 3, '2026-08-31', 'Atendimento do agendamento 36', 'Concluído', 36) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (29, 1, 1, 1, '2026-09-01', 'Atendimento do agendamento 37', 'Concluído', 37) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (30, 8, 1, 2, '2026-09-04', 'Atendimento do agendamento 39', 'Concluído', 39) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (31, 15, 1, 2, '2026-09-11', 'Atendimento do agendamento 43', 'Concluído', 43) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (32, 13, 3, 3, '2026-09-14', 'Atendimento do agendamento 44', 'Concluído', 44) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (33, 12, 2, 2, '2026-09-18', 'Atendimento do agendamento 47', 'Concluído', 47) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (34, 11, 3, 3, '2026-09-21', 'Atendimento do agendamento 48', 'Concluído', 48) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (35, 5, 2, 1, '2026-09-23', 'Atendimento do agendamento 50', 'Concluído', 50) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (36, 9, 2, 2, '2026-09-25', 'Atendimento do agendamento 51', 'Concluído', 51) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (37, 3, 3, 3, '2026-09-28', 'Atendimento do agendamento 52', 'Concluído', 52) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (38, 8, 1, 2, '2026-09-28', 'Atendimento do agendamento 53', 'Concluído', 53) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (39, 6, 2, 1, '2026-09-30', 'Atendimento do agendamento 54', 'Concluído', 54) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (40, 4, 3, 3, '2026-10-02', 'Atendimento do agendamento 55', 'Concluído', 55) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (41, 12, 3, 3, '2026-10-05', 'Atendimento do agendamento 57', 'Concluído', 57) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (42, 8, 1, 2, '2026-10-09', 'Atendimento do agendamento 59', 'Concluído', 59) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (43, 16, 1, 2, '2026-10-12', 'Atendimento do agendamento 60', 'Concluído', 60) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (44, 8, 3, 3, '2026-10-12', 'Atendimento do agendamento 61', 'Concluído', 61) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (45, 10, 1, 2, '2026-10-14', 'Atendimento do agendamento 62', 'Concluído', 62) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (46, 15, 2, 2, '2026-10-16', 'Atendimento do agendamento 63', 'Concluído', 63) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (47, 10, 1, 2, '2026-10-21', 'Atendimento do agendamento 66', 'Concluído', 66) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (48, 18, 2, 1, '2026-10-23', 'Atendimento do agendamento 67', 'Concluído', 67) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (49, 2, 2, 2, '2026-10-26', 'Atendimento do agendamento 68', 'Concluído', 68) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;
INSERT INTO `atendimento` (`id_atendimento`, `id_paciente`, `id_profissional`, `id_consultorio`, `data`, `descricao`, `status`, `id_agendamento`) VALUES (50, 5, 1, 2, '2026-10-26', 'Atendimento do agendamento 69', 'Concluído', 69) ON DUPLICATE KEY UPDATE `id_atendimento` = `id_atendimento`;

-- atendimento_procedimento (83 registros)
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (1, 1, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (2, 1, 10, 1, 2200) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (3, 1, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (4, 2, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (5, 2, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (6, 3, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (7, 4, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (8, 5, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (9, 5, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (10, 6, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (11, 6, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (12, 7, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (13, 8, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (14, 8, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (15, 9, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (16, 9, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (17, 10, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (18, 10, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (19, 11, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (20, 12, 10, 1, 2200) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (21, 12, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (22, 12, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (23, 13, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (24, 13, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (25, 14, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (26, 14, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (27, 15, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (28, 16, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (29, 16, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (30, 17, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (31, 17, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (32, 17, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (33, 18, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (34, 19, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (35, 19, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (36, 20, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (37, 21, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (38, 21, 10, 1, 2200) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (39, 22, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (40, 22, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (41, 23, 10, 1, 2200) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (42, 24, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (43, 25, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (44, 26, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (45, 26, 3, 1, 250) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (46, 27, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (47, 28, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (48, 29, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (49, 29, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (50, 30, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (51, 31, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (52, 31, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (53, 32, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (54, 33, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (55, 33, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (56, 34, 3, 1, 250) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (57, 34, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (58, 35, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (59, 35, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (60, 36, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (61, 37, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (62, 38, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (63, 38, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (64, 39, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (65, 39, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (66, 40, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (67, 40, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (68, 40, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (69, 41, 3, 1, 250) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (70, 41, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (71, 42, 7, 1, 60) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (72, 43, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (73, 44, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (74, 44, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (75, 44, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (76, 45, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (77, 45, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (78, 46, 4, 1, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (79, 47, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (80, 48, 1, 1, 120) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (81, 49, 8, 1, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (82, 49, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `atendimento_procedimento` (`id`, `id_atendimento`, `id_procedimento`, `quantidade`, `valor_cobrado`) VALUES (83, 50, 9, 1, 160) ON DUPLICATE KEY UPDATE `id` = `id`;

-- plano_tratamento (8 registros)
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (1, 2, 1, 'Tratamento de canal + restauração', '2026-08-01', '2026-10-30', 'Em andamento') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (2, 5, 3, 'Tratamento ortodôntico (manutenções mensais)', '2026-07-10', '2027-07-10', 'Em andamento') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (3, 8, 2, 'Reabilitação com prótese total', '2026-09-01', '2026-12-15', 'Em andamento') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (4, 11, 1, 'Clareamento + profilaxia', '2026-06-05', '2026-07-20', 'Concluído') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (5, 14, 2, 'Extrações e restaurações', '2026-09-20', '2026-11-30', 'Em andamento') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (6, 17, 3, 'Alinhadores ortodônticos', '2026-10-01', '2027-10-01', 'Em andamento') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (7, 3, 1, 'Prevenção e acompanhamento semestral', '2026-01-15', '2026-06-30', 'Concluído') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;
INSERT INTO `plano_tratamento` (`id_plano`, `id_paciente`, `id_profissional`, `descricao`, `data_inicio`, `data_prevista_fim`, `situacao`) VALUES (8, 19, 2, 'Tratamento de canal', '2026-10-10', '2026-12-10', 'Aguardando início') ON DUPLICATE KEY UPDATE `id_plano` = `id_plano`;

-- plano_procedimento (12 registros)
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (1, 1, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (2, 1, 3, 2, 250) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (3, 2, 9, 12, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (4, 3, 10, 1, 2200) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (5, 4, 6, 1, 900) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (6, 4, 2, 1, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (7, 5, 4, 2, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (8, 5, 3, 3, 250) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (9, 6, 9, 12, 160) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (10, 7, 2, 2, 180) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (11, 7, 8, 2, 70) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `plano_procedimento` (`id`, `id_plano`, `id_procedimento`, `quantidade`, `valor_previsto`) VALUES (12, 8, 5, 1, 800) ON DUPLICATE KEY UPDATE `id` = `id`;

-- pagamento (50 registros)
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (1, 1, 2450, '2026-07-02', 'PIX', 'Cancelado') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (2, 2, 220, NULL, 'PIX', 'Pendente') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (3, 3, 300, '2026-07-06', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (4, 4, 180, '2026-07-07', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (5, 5, 370, '2026-07-09', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (6, 6, 190, '2026-07-13', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (7, 7, 300, '2026-07-14', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (8, 8, 340, '2026-07-16', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (9, 9, 360, NULL, 'Cartão de crédito', 'Pendente') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (10, 10, 230, '2026-07-20', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (11, 11, 120, '2026-07-21', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (12, 12, 3260, '2026-07-27', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (13, 13, 1080, '2026-07-28', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (14, 14, 960, '2026-08-03', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (15, 15, 300, '2026-08-04', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (16, 16, 920, '2026-08-06', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (17, 17, 460, NULL, 'Cartão de crédito', 'Pendente') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (18, 18, 120, '2026-08-10', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (19, 19, 220, '2026-08-11', 'Cartão de crédito', 'Cancelado') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (20, 20, 900, '2026-08-13', 'Dinheiro', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (21, 21, 2500, '2026-08-14', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (22, 22, 980, '2026-08-17', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (23, 23, 2200, '2026-08-18', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (24, 24, 160, NULL, 'PIX', 'Pendente') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (25, 25, 800, '2026-08-24', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (26, 26, 310, '2026-08-25', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (27, 27, 900, '2026-08-27', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (28, 28, 800, '2026-08-31', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (29, 29, 360, '2026-09-01', 'Dinheiro', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (30, 30, 70, '2026-09-04', 'Dinheiro', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (31, 31, 1060, '2026-09-11', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (32, 32, 60, '2026-09-14', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (33, 33, 1100, '2026-09-18', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (34, 34, 410, '2026-09-21', 'Dinheiro', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (35, 35, 1200, '2026-09-23', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (36, 36, 160, '2026-09-25', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (37, 37, 300, '2026-09-28', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (38, 38, 1700, '2026-09-28', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (39, 39, 360, '2026-09-30', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (40, 40, 1080, '2026-10-02', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (41, 41, 410, NULL, 'Cartão de débito', 'Pendente') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (42, 42, 60, '2026-10-09', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (43, 43, 800, '2026-10-12', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (44, 44, 530, '2026-10-12', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (45, 45, 970, '2026-10-14', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (46, 46, 300, '2026-10-16', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (47, 47, 160, '2026-10-21', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (48, 48, 120, '2026-10-23', 'Cartão de débito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (49, 49, 250, '2026-10-26', 'Cartão de crédito', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;
INSERT INTO `pagamento` (`id_pagamento`, `id_atendimento`, `valor`, `data_pagamento`, `forma_pagamento`, `situacao_financeira`) VALUES (50, 50, 160, '2026-10-26', 'PIX', 'Pago') ON DUPLICATE KEY UPDATE `id_pagamento` = `id_pagamento`;

-- compra (6 registros)
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (1, 1, 8, '2026-07-02', '2026-07-06', 'Recebida') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (2, 2, 8, '2026-08-04', '2026-08-08', 'Recebida') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (3, 4, 8, '2026-09-01', '2026-09-05', 'Recebida') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (4, 1, 8, '2026-10-05', '2026-10-09', 'Recebida') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (5, 3, 8, '2026-10-20', NULL, 'Em trânsito') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;
INSERT INTO `compra` (`id_compra`, `id_fornecedor`, `id_funcionario`, `data_compra`, `data_recebimento`, `situacao`) VALUES (6, 2, 8, '2026-11-03', NULL, 'Solicitada') ON DUPLICATE KEY UPDATE `id_compra` = `id_compra`;

-- item_compra (12 registros)
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (1, 1, 1, 20, 30, 600) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (2, 1, 2, 30, 17, 510) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (3, 1, 8, 20, 20, 400) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (4, 2, 3, 10, 92, 920) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (5, 2, 4, 10, 75, 750) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (6, 3, 12, 10, 43, 430) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (7, 3, 13, 5, 105, 525) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (8, 4, 1, 15, 31.5, 472.5) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (9, 4, 5, 10, 13, 130) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (10, 4, 15, 6, 23, 138) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (11, 5, 6, 5, 60, 300) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_compra` (`id`, `id_compra`, `id_material`, `quantidade`, `valor_unitario`, `valor_total`) VALUES (12, 6, 3, 10, 93, 930) ON DUPLICATE KEY UPDATE `id` = `id`;

-- producao (8 registros)
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (1, 'Coroa provisória', 4, 3, '2026-07-08', '2026-07-10', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (2, 'Prótese total superior', 4, 1, '2026-07-15', '2026-08-05', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (3, 'Placa de bruxismo', 4, 2, '2026-08-10', '2026-08-14', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (4, 'Protetor bucal', 4, 2, '2026-09-01', '2026-09-03', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (5, 'Coroa provisória', 4, 4, '2026-09-12', '2026-09-15', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (6, 'Prótese total inferior', 4, 1, '2026-10-01', '2026-10-28', 'Em andamento') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (7, 'Placa de bruxismo', 4, 1, '2026-10-12', '2026-10-16', 'Concluída') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;
INSERT INTO `producao` (`id_producao`, `tipo_producao`, `id_responsavel`, `quantidade`, `data_inicio`, `data_fim`, `status`) VALUES (8, 'Aparelho removível', 4, 1, '2026-10-20', NULL, 'Em andamento') ON DUPLICATE KEY UPDATE `id_producao` = `id_producao`;

-- item_producao (11 registros)
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (1, 1, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (2, 2, 9, 2) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (3, 2, 11, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (4, 2, 10, 2) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (5, 3, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (6, 4, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (7, 5, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (8, 6, 9, 2) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (9, 6, 11, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (10, 7, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;
INSERT INTO `item_producao` (`id`, `id_producao`, `id_material`, `quantidade_consumida`) VALUES (11, 8, 10, 1) ON DUPLICATE KEY UPDATE `id` = `id`;

-- movimentacao_estoque (30 registros)
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (1, 1, 'Entrada', 20, '2026-07-06', 8, 'Compra #1', 1, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (2, 2, 'Entrada', 30, '2026-07-06', 8, 'Compra #1', 1, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (3, 8, 'Entrada', 20, '2026-07-06', 8, 'Compra #1', 1, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (4, 10, 'Saída', 1, '2026-07-08', 4, 'Produção #1', NULL, 1) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (5, 9, 'Saída', 2, '2026-07-15', 4, 'Produção #2', NULL, 2) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (6, 11, 'Saída', 1, '2026-07-15', 4, 'Produção #2', NULL, 2) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (7, 10, 'Saída', 2, '2026-07-15', 4, 'Produção #2', NULL, 2) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (8, 3, 'Entrada', 10, '2026-08-08', 8, 'Compra #2', 2, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (9, 4, 'Entrada', 10, '2026-08-08', 8, 'Compra #2', 2, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (10, 10, 'Saída', 1, '2026-08-10', 4, 'Produção #3', NULL, 3) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (11, 10, 'Saída', 1, '2026-09-01', 4, 'Produção #4', NULL, 4) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (12, 3, 'Saída', 4, '2026-09-01', 6, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (13, 12, 'Entrada', 10, '2026-09-05', 8, 'Compra #3', 3, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (14, 13, 'Entrada', 5, '2026-09-05', 8, 'Compra #3', 3, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (15, 8, 'Saída', 1, '2026-09-05', 5, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (16, 2, 'Saída', 2, '2026-09-09', 6, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (17, 10, 'Saída', 1, '2026-09-12', 4, 'Produção #5', NULL, 5) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (18, 1, 'Saída', 2, '2026-09-13', 5, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (19, 2, 'Saída', 1, '2026-09-17', 5, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (20, 1, 'Saída', 4, '2026-09-21', 6, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (21, 8, 'Saída', 4, '2026-09-25', 6, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (22, 1, 'Saída', 2, '2026-09-29', 6, 'Uso em atendimento', NULL, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (23, 9, 'Saída', 2, '2026-10-01', 4, 'Produção #6', NULL, 6) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (24, 11, 'Saída', 1, '2026-10-01', 4, 'Produção #6', NULL, 6) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (25, 1, 'Entrada', 15, '2026-10-09', 8, 'Compra #4', 4, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (26, 5, 'Entrada', 10, '2026-10-09', 8, 'Compra #4', 4, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (27, 15, 'Entrada', 6, '2026-10-09', 8, 'Compra #4', 4, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (28, 10, 'Saída', 1, '2026-10-12', 4, 'Produção #7', NULL, 7) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (29, 6, 'Entrada', 5, '2026-10-20', 8, 'Compra #5', 5, NULL) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;
INSERT INTO `movimentacao_estoque` (`id_movimentacao`, `id_material`, `tipo`, `quantidade`, `data`, `id_responsavel`, `origem`, `id_compra`, `id_producao`) VALUES (30, 10, 'Saída', 1, '2026-10-20', 4, 'Produção #8', NULL, 8) ON DUPLICATE KEY UPDATE `id_movimentacao` = `id_movimentacao`;

-- esterilizacao (30 registros)
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (1, 4, 9, '2026-07-01 07:59:59', '2026-07-01 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (2, 5, 9, '2026-07-06 07:59:59', '2026-07-06 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (3, 4, 9, '2026-07-09 07:59:59', '2026-07-09 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (4, 4, 9, '2026-07-13 07:59:59', '2026-07-13 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (5, 4, 9, '2026-07-17 07:59:59', '2026-07-17 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (6, 4, 9, '2026-07-21 07:59:59', '2026-07-21 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (7, 4, 9, '2026-07-27 07:59:59', '2026-07-27 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (8, 4, 9, '2026-07-29 07:59:59', '2026-07-29 09:15:00', 'Instrumental', 'Reprovado', 'Falha no indicador biológico') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (9, 4, 9, '2026-08-03 07:59:59', '2026-08-03 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (10, 4, 9, '2026-08-06 07:59:59', '2026-08-06 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (11, 4, 9, '2026-08-10 07:59:59', '2026-08-10 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (12, 4, 9, '2026-08-14 07:59:59', '2026-08-14 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (13, 4, 9, '2026-08-18 07:59:59', '2026-08-18 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (14, 5, 9, '2026-08-24 07:59:59', '2026-08-24 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (15, 5, 9, '2026-08-26 07:59:59', '2026-08-26 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (16, 4, 9, '2026-08-31 07:59:59', '2026-08-31 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (17, 4, 9, '2026-09-03 07:59:59', '2026-09-03 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (18, 4, 9, '2026-09-07 07:59:59', '2026-09-07 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (19, 4, 9, '2026-09-11 07:59:59', '2026-09-11 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (20, 4, 9, '2026-09-15 07:59:59', '2026-09-15 09:15:00', 'Instrumental', 'Reprovado', 'Falha no indicador biológico') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (21, 4, 9, '2026-09-21 07:59:59', '2026-09-21 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (22, 4, 9, '2026-09-23 07:59:59', '2026-09-23 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (23, 4, 9, '2026-09-28 07:59:59', '2026-09-28 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (24, 5, 9, '2026-10-01 07:59:59', '2026-10-01 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (25, 5, 9, '2026-10-05 07:59:59', '2026-10-05 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (26, 4, 9, '2026-10-09 07:59:59', '2026-10-09 09:15:00', 'Têxteis', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (27, 4, 9, '2026-10-13 07:59:59', '2026-10-13 09:15:00', 'Têxteis', 'Reprovado', 'Falha no indicador biológico') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (28, 4, 9, '2026-10-19 07:59:59', '2026-10-19 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (29, 4, 9, '2026-10-21 07:59:59', '2026-10-21 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;
INSERT INTO `esterilizacao` (`id_ciclo`, `id_equipamento`, `id_responsavel`, `inicio_ciclo`, `fim_ciclo`, `tipo`, `resultado`, `observacoes`) VALUES (30, 4, 9, '2026-10-26 07:59:59', '2026-10-26 09:15:00', 'Instrumental', 'Aprovado', 'Sem observações') ON DUPLICATE KEY UPDATE `id_ciclo` = `id_ciclo`;

COMMIT;

-- Consultas rápidas para conferência:
SELECT COUNT(*) AS total_pacientes FROM paciente;
SELECT COUNT(*) AS total_atendimentos FROM atendimento;
SELECT COUNT(*) AS total_agendamentos FROM agendamento;
SELECT COUNT(*) AS total_movimentacoes FROM movimentacao_estoque;
-- Extensão de demonstração — executar após a criação e carga do banco.
USE odontologia_sasaki_atualizado;
-- SELECT com JOIN — Quais atendimentos têm pacientes e profissionais identificados?
SELECT a.id_atendimento, a.data, p.nome AS paciente, f.nome AS profissional, c.nome_consultorio
FROM atendimento a JOIN paciente p ON p.id_paciente=a.id_paciente
JOIN funcionario f ON f.id_funcionario=a.id_profissional
JOIN consultorio c ON c.id_consultorio=a.id_consultorio LIMIT 20;

-- UPDATE de demonstração, reversível: executa e desfaz (não modifica os dados finais).
START TRANSACTION;
UPDATE material SET estoque_minimo=estoque_minimo+1 WHERE id_material=1;
SELECT id_material, estoque_minimo FROM material WHERE id_material=1;
ROLLBACK;
-- DELETE de demonstração, reversível: registro isolado criado só para demonstrar.
START TRANSACTION;
INSERT INTO fornecedor (razao_social,status) VALUES ('Fornecedor temporário de demonstração','Inativo');
DELETE FROM fornecedor WHERE id_fornecedor = LAST_INSERT_ID()
  AND razao_social = 'Fornecedor temporário de demonstração' AND cnpj IS NULL;
ROLLBACK;

-- G01 — Quantos agendamentos há por mês e situação? Atende P1 e KPI de volume de agenda.
SELECT DATE_FORMAT(data,'%Y-%m') AS mes,situacao,COUNT(*) AS quantidade
FROM agendamento GROUP BY DATE_FORMAT(data,'%Y-%m'),situacao ORDER BY mes,situacao;
-- G02 — Qual é o percentual de agendamentos cancelados por mês? Atende P1 e KPI de cancelamento.
SELECT DATE_FORMAT(data,'%Y-%m') AS mes,COUNT(*) AS total,
 SUM(CASE WHEN LOWER(situacao) LIKE '%cancel%' THEN 1 ELSE 0 END) AS cancelados,
 ROUND(100.0*SUM(CASE WHEN LOWER(situacao) LIKE '%cancel%' THEN 1 ELSE 0 END)/COUNT(*),2) AS taxa_cancelamento_pct
FROM agendamento GROUP BY DATE_FORMAT(data,'%Y-%m') ORDER BY mes;
-- G03 — Quantos atendimentos foram registrados por profissional/mês? Atende P2 e KPI de produtividade.
SELECT DATE_FORMAT(a.data,'%Y-%m') AS mes,f.nome AS profissional,COUNT(*) AS atendimentos
FROM atendimento a JOIN funcionario f ON f.id_funcionario=a.id_profissional
GROUP BY DATE_FORMAT(a.data,'%Y-%m'),f.id_funcionario,f.nome ORDER BY mes,atendimentos DESC;
-- G04 — Qual valor dos pagamentos por mês e situação? Atende P3 e KPI financeiro.
SELECT DATE_FORMAT(data_pagamento,'%Y-%m') AS mes,situacao_financeira,
 COUNT(*) AS registros,SUM(valor) AS valor_total
FROM pagamento GROUP BY DATE_FORMAT(data_pagamento,'%Y-%m'),situacao_financeira ORDER BY mes;
-- G05 — Qual valor médio de pagamentos por atendimento, por mês? Atende P3 e KPI ticket médio.
SELECT DATE_FORMAT(a.data,'%Y-%m') AS mes,COUNT(DISTINCT a.id_atendimento) AS atendimentos_com_pagamento,
 ROUND(SUM(p.valor)/NULLIF(COUNT(DISTINCT a.id_atendimento),0),2) AS valor_medio_por_atendimento
FROM atendimento a JOIN pagamento p ON p.id_atendimento=a.id_atendimento
GROUP BY DATE_FORMAT(a.data,'%Y-%m') ORDER BY mes;
-- G06 — Quais materiais estão em nível igual ou inferior ao estoque mínimo? Atende P4 e KPI de ruptura.
SELECT id_material,nome,quantidade_estoque,estoque_minimo
FROM material WHERE quantidade_estoque<=estoque_minimo ORDER BY quantidade_estoque;
-- G07 — Quantas manutenções por equipamento e status? Atende P5 e KPI de manutenção.
SELECT e.nome AS equipamento,m.status,COUNT(*) AS total,COALESCE(SUM(m.custo),0) AS custo_total
FROM manutencao m JOIN equipamento e ON e.id_equipamento=m.id_equipamento
GROUP BY e.id_equipamento,e.nome,m.status ORDER BY total DESC;
-- G08 — Qual a taxa de reprovação dos ciclos de esterilização por mês? Atende P6 e KPI de esterilização.
SELECT DATE_FORMAT(inicio_ciclo,'%Y-%m') AS mes,COUNT(*) AS ciclos,
 SUM(CASE WHEN LOWER(resultado) LIKE '%reprov%' THEN 1 ELSE 0 END) AS reprovados,
 ROUND(100.0*SUM(CASE WHEN LOWER(resultado) LIKE '%reprov%' THEN 1 ELSE 0 END)/COUNT(*),2) AS taxa_reprovacao_pct
FROM esterilizacao GROUP BY DATE_FORMAT(inicio_ciclo,'%Y-%m') ORDER BY mes;
-- G09 — Qual volume de compras por fornecedor? Atende P4 e KPI de suprimentos.
SELECT f.razao_social,COUNT(DISTINCT c.id_compra) AS compras,COALESCE(SUM(ic.quantidade*ic.valor_unitario),0) AS valor_total
FROM fornecedor f LEFT JOIN compra c ON c.id_fornecedor=f.id_fornecedor
LEFT JOIN item_compra ic ON ic.id_compra=c.id_compra
GROUP BY f.id_fornecedor,f.razao_social ORDER BY valor_total DESC;
-- G10 — Quantos planos estão ativos em cada situação? Atende P2 e KPI de acompanhamento.
SELECT situacao,COUNT(*) AS planos FROM plano_tratamento GROUP BY situacao;
-- G11 — Qual consumo registrado de materiais por mês? Atende P4 e KPI de consumo.
SELECT DATE_FORMAT(me.data,'%Y-%m') AS mes,m.nome AS material,SUM(me.quantidade) AS quantidade_saidas
FROM movimentacao_estoque me JOIN material m ON m.id_material=me.id_material
WHERE LOWER(me.tipo) LIKE 'sa%da%' OR LOWER(me.tipo) LIKE 'saida%'
GROUP BY DATE_FORMAT(me.data,'%Y-%m'),m.id_material,m.nome ORDER BY mes,quantidade_saidas DESC;

-- A01 — Há atendimentos relacionados a agendamentos de outros pacientes? Verifica RN04.
SELECT a.id_atendimento,a.id_paciente AS paciente_atendimento,g.id_paciente AS paciente_agendamento
FROM atendimento a JOIN agendamento g ON g.id_agendamento=a.id_agendamento
WHERE a.id_paciente<>g.id_paciente;
-- A02 — Existem atendimentos sem procedimento associado? Verifica RN05 (revisar exceções com a clínica).
SELECT a.id_atendimento FROM atendimento a LEFT JOIN atendimento_procedimento ap ON ap.id_atendimento=a.id_atendimento
GROUP BY a.id_atendimento HAVING COUNT(ap.id)=0;
-- A03 — Existem saldos de estoque negativos? Verifica RN08.
SELECT id_material,nome,quantidade_estoque FROM material WHERE quantidade_estoque<0;
-- A04 — Há movimentações referenciando simultaneamente compra e produção? Verifica RN09.
SELECT id_movimentacao,id_compra,id_producao FROM movimentacao_estoque WHERE id_compra IS NOT NULL AND id_producao IS NOT NULL;
-- A05 — Há ciclos terminando antes do início? Verifica RN11.
SELECT id_ciclo,inicio_ciclo,fim_ciclo FROM esterilizacao WHERE fim_ciclo<inicio_ciclo;
-- A06 — Existem quantidades nulas ou não positivas nos itens de compra? Verifica RN07.
SELECT id,id_compra,quantidade FROM item_compra WHERE quantidade<=0 OR quantidade IS NULL;
-- A07 — Há pagamento com data vazia, mesmo constando como pago? Verifica RN06 (revisar status com clínica).
SELECT id_pagamento,situacao_financeira,data_pagamento FROM pagamento
WHERE LOWER(situacao_financeira) IN ('pago','quitado','concluido','concluído') AND data_pagamento IS NULL;
-- A08 — Há manutenções encerradas antes da abertura? Verifica RN10.
SELECT id_manutencao,data_inicio,data_fim FROM manutencao WHERE data_fim<data_inicio;
