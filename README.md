# 🦷 ODONTOLOGIA SASAKI
## Sistema de Gestão de Informações Odontológicas

### ENTREGA 2 — MODELO LÓGICO, IMPLEMENTAÇÃO SQL E APRESENTAÇÃO FINAL

**Organização:** Odontologia Sasaki  
**Projeto:** Sistema de Gestão de Informações para Organização de Pequeno Porte  
**SGBD:** MySQL 8.0  
**Modelagem:** brModelo Web e Mermaid  
**Linguagem:** SQL  
**Ano:** 2026  

> Projeto acadêmico baseado em uma organização real, com dados fictícios utilizados para simular operações e testar o banco de dados.

---

# 📑 SUMÁRIO

1. Relatório Técnico Final
   - 1.1 Revisão do Modelo Conceitual
   - 1.2 Conversão para o Modelo Lógico
   - 1.3 Chaves Primárias e Estrangeiras
   - 1.4 Normalização
   - 1.5 Justificativas Técnicas
   - 1.6 Arquitetura Analítica para BI e IA
2. Modelo Lógico Relacional
3. Script SQL Completo
4. Massa de Dados
5. Repositório GitHub
6. Uso de Inteligência Artificial
7. Apresentação Final
8. Conclusão

---

# 👥 INTEGRANTES

| Nome completo | RGM | GitHub |
|---|---|---|
|Letícia Valentim Reges|047369680|
|Juan Arthur Franco|47232099|
|Isadora Do Nascimento Takami|47108932|
|Pedro Cândido Pyramides Pinheiro|04669634|

---

# 1. RELATÓRIO TÉCNICO FINAL

## 1.1 Revisão do Modelo Conceitual

### 1.1.1 Caracterização da Organização

A **Odontologia Sasaki** é uma clínica odontológica dedicada à prestação de serviços relacionados à saúde bucal.

A organização oferece serviços odontológicos, incluindo:

- Odontologia especializada;
- Implantes dentários;
- Estética odontológica;
- Próteses dentárias.

O funcionamento de uma clínica exige a integração de diferentes processos administrativos, financeiros e operacionais.

Entre esses processos estão o cadastramento de pacientes, agendamento de consultas, realização de atendimentos, utilização de materiais, manutenção de equipamentos e controle financeiro.

O presente projeto propõe o desenvolvimento de um banco de dados relacional capaz de centralizar essas informações.

### Contexto e Porte da Organização

Para a elaboração do modelo, foi considerado um cenário operacional da clínica odontológica.

| Informação | Quantidade simulada |
|---|---:|
| Funcionários | 10 |
| Consultórios | 6 |
| Pacientes cadastrados na amostra | 20 |
| Agendamentos mensais | 35 |
| Atendimentos mensais | 25 |
| Equipamentos | 10 |
| Materiais cadastrados | 15 |
| Fornecedores | 5 |

>Os valores foram utilizados como referência para criar a massa de dados acadêmica.
>O cenário representa aproximadamente dois meses de atividades, considerando 70 agendamentos e 50 atendimentos.

### Justificativa da Escolha

A Odontologia Sasaki foi escolhida como objeto de estudo por apresentar processos que podem ser representados em um banco de dados relacional.

A gestão de uma clínica odontológica envolve diversos relacionamentos entre informações.

Por exemplo:

- Um paciente pode possuir vários agendamentos;
- Um funcionário pode realizar diferentes atendimentos;
- Um consultório pode receber vários pacientes;
- Um atendimento pode possuir diferentes procedimentos;
- Um equipamento pode passar por várias manutenções;
- Um fornecedor pode participar de diferentes compras;
- Um material pode apresentar várias movimentações de estoque.

Essas características permitem aplicar os conceitos de modelagem conceitual, lógica e física.

O sistema proposto busca organizar informações de maneira centralizada, facilitando consultas, análises e o acompanhamento das atividades.

---

### 1.1.2 Evidências da Organização

As imagens abaixo foram disponibilizadas pelo grupo como evidências visuais da organização.

#### Fachada da Odontologia Sasaki

<p align="center">
  <img src="Evidencias%20da%20entrevista/PORTA%20CL%C3%8DNICA.png" alt="Fachada da Odontologia Sasaki" width="550">
</p>

A fotografia apresenta a fachada da clínica, incluindo a identificação comercial da Odontologia Sasaki.

#### Registro Fotográfico no Ambiente Clínico

<p align="center">
  <img src="Evidencias%20da%20entrevista/Foto%20com%20o%20doutor%20marcelo.png" alt="Registro fotográfico na clínica" width="550">
</p>

A fotografia apresenta um registro realizado no ambiente clínico

#### Dados da Organização

| Informação | Descrição |
|---|---|
| Nome | Odontologia Sasaki |
|Endereço| R. Jardim Tamoio, 1089 - Conj. Res. José Bonifácio, São Paulo - SP, 08255-010|
|Google Maps|[Acessar localização no Google Maps](https://maps.app.goo.gl/ALuZBqSGNaq6kBxy9) |
| E-mail | `Luduque@hotmail.com` |
| Telefone | `+55 11 99001-2968` |
|CRO- Clinica| 025226|
|CRO- DRA.Luana Sasaki| 104086|

---

### 1.1.3 Levantamento de Requisitos

Para construir o sistema, foram considerados os principais processos administrativos e operacionais de uma clínica odontológica.


#### Entrevista 
#### Pergunta 1 — Como são realizados os agendamentos?

**Resposta:**

Os agendamentos são organizados pela recepção, considerando o paciente, o profissional responsável, o consultório disponível, a data e o horário.

Também é necessário registrar cancelamentos e remarcações.

**Necessidade identificada:**

Criar uma estrutura que permita controlar os agendamentos e consultar sua situação.

**Tabelas envolvidas:**

- paciente;
- funcionario;
- consultorio;
- agendamento.

#### Pergunta 2 — Como são registrados os atendimentos?

**Resposta:**

Cada atendimento precisa estar relacionado ao paciente e ao profissional responsável.

Também é importante registrar os procedimentos realizados e os valores associados.

**Necessidade identificada:**

Centralizar o histórico de atendimentos e procedimentos.

**Tabelas envolvidas:**

- atendimento;
- procedimento;
- atendimento_procedimento.

#### Pergunta 3 — Como funciona o controle financeiro?

**Resposta:**

Os pagamentos precisam ser relacionados aos atendimentos.

Cada registro deve conter valor, forma de pagamento, data e situação.

**Necessidade identificada:**

Permitir o acompanhamento de pagamentos por período.

**Tabelas envolvidas:**

- pagamento;
- atendimento.

#### Pergunta 4 — Como é realizado o controle de materiais?

**Resposta:**

A clínica precisa acompanhar a quantidade disponível de cada material, registrar entradas e saídas e identificar quando o estoque estiver abaixo do mínimo.

**Necessidade identificada:**

Criar um controle de estoque integrado às compras.

**Tabelas envolvidas:**

- material;
- fornecedor;
- compra;
- item_compra;
- movimentacao_estoque.

#### Pergunta 5 — Como são acompanhados os equipamentos?

**Resposta:**

Os equipamentos precisam possuir identificação individual e histórico de manutenção.

É necessário registrar datas, responsáveis, tipos de manutenção e custos.

**Necessidade identificada:**

Criar um histórico de manutenção dos equipamentos.

**Tabelas envolvidas:**

- equipamento;
- manutencao;
- funcionario.

#### Pergunta 6 — Como funciona o controle de esterilização?

**Resposta:**

Os ciclos de esterilização precisam ser registrados para permitir o acompanhamento dos resultados e dos profissionais responsáveis.

**Necessidade identificada:**

Armazenar o histórico de ciclos e possíveis falhas.

**Tabelas envolvidas:**

- esterilizacao;
- equipamento;
- funcionario.



---

### 1.1.4 Problemas e Necessidades Identificados

Foram definidos seis problemas de gestão de informações para orientar a modelagem.

#### P1 — Controle de Agendamentos

Dificuldade potencial para acompanhar horários, cancelamentos e remarcações.

**Solução:** centralizar os registros de agendamento.

**Consulta:** G01 e G02.

#### P2 — Histórico de Atendimentos

Necessidade de acompanhar os procedimentos realizados por paciente e profissional.

**Solução:** relacionar pacientes, atendimentos e procedimentos.

**Consulta:** G03 e G10.

#### P3 — Controle Financeiro

Necessidade de consultar pagamentos e valores registrados.

**Solução:** organizar os pagamentos por atendimento e período.

**Consulta:** G04 e G05.

#### P4 — Gestão de Estoque

Necessidade de identificar materiais com estoque baixo.

**Solução:** integrar materiais, compras e movimentações.

**Consulta:** G06, G09 e G11.

#### P5 — Manutenção de Equipamentos

Necessidade de acompanhar custos e intervenções técnicas.

**Solução:** manter histórico de manutenção dos equipamentos.

**Consulta:** G07.

#### P6 — Controle de Esterilização

Necessidade de registrar e consultar resultados dos ciclos.

**Solução:** armazenar os registros de esterilização.

**Consulta:** G08.

---

### 1.1.5 Escopo do Sistema

O sistema foi projetado para gerenciar informações relacionadas a diferentes áreas.

#### Gestão de Pessoas

- Cadastro de pacientes;
- Cadastro de funcionários;
- Cadastro de responsáveis.

#### Gestão Clínica

- Agendamentos;
- Atendimentos;
- Procedimentos;
- Planos de tratamento.

#### Gestão Financeira

- Pagamentos;
- Valores dos atendimentos;
- Compras.

#### Gestão de Suprimentos

- Materiais;
- Fornecedores;
- Compras;
- Movimentações de estoque.

#### Gestão Operacional

- Consultórios;
- Equipamentos;
- Manutenção;
- Produção;
- Esterilização.

O modelo atual não contempla prontuários odontológicos completos, exames de imagem, folha de pagamento ou emissão de notas fiscais.



---

### 1.1.6 Processos de Negócio

| Código | Processo | Descrição |
|---|---|---|
| PN01 | Cadastro de pacientes | Registro de informações pessoais e contatos. |
| PN02 | Cadastro de funcionários | Registro dos profissionais e suas funções. |
| PN03 | Gestão de consultórios | Controle das salas e situações operacionais. |
| PN04 | Agendamento | Registro de consultas e horários. |
| PN05 | Atendimento | Registro dos atendimentos realizados. |
| PN06 | Procedimentos | Associação dos procedimentos aos atendimentos. |
| PN07 | Plano de tratamento | Planejamento dos procedimentos. |
| PN08 | Pagamentos | Controle dos registros financeiros. |
| PN09 | Fornecedores | Cadastro de fornecedores. |
| PN10 | Compras | Registro das compras de materiais. |
| PN11 | Estoque | Controle de entradas e saídas. |
| PN12 | Produção | Registro de atividades de produção. |
| PN13 | Equipamentos | Cadastro e acompanhamento dos equipamentos. |
| PN14 | Manutenção | Histórico das intervenções técnicas. |
| PN15 | Esterilização | Registro de ciclos de esterilização. |

---

### 1.1.7 Requisitos Funcionais

| Código | Requisito |
|---|---|
| RF01 | Cadastrar pacientes com nome, CPF, telefone, e-mail, nascimento, endereço e convênio. |
| RF02 | Cadastrar funcionários com nome, CPF, cargo, contatos, admissão e situação. |
| RF03 | Cadastrar consultórios com identificação, número da sala, andar e status. |
| RF04 | Registrar agendamentos com paciente, profissional, consultório, data, horário e situação. |
| RF05 | Registrar atendimentos associados aos pacientes e profissionais. |
| RF06 | Cadastrar procedimentos e valores. |
| RF07 | Associar múltiplos procedimentos a um atendimento. |
| RF08 | Cadastrar planos de tratamento. |
| RF09 | Registrar pagamentos associados aos atendimentos. |
| RF10 | Cadastrar fornecedores. |
| RF11 | Cadastrar materiais e controlar estoque mínimo. |
| RF12 | Registrar compras e seus respectivos itens. |
| RF13 | Registrar entradas e saídas de materiais. |
| RF14 | Registrar processos de produção e materiais utilizados. |
| RF15 | Cadastrar equipamentos e seus responsáveis. |
| RF16 | Registrar manutenções e custos. |
| RF17 | Registrar ciclos de esterilização. |
| RF18 | Consultar agendamentos por período. |
| RF19 | Consultar pagamentos registrados. |
| RF20 | Identificar materiais abaixo do estoque mínimo. |
| RF21 | Consultar histórico de manutenções. |
| RF22 | Gerar indicadores gerenciais por meio de consultas SQL. |

---

### 1.1.8 Requisitos Não Funcionais

| Código | Requisito |
|---|---|
| RNF01 | Utilizar MySQL 8.0 como SGBD. |
| RNF02 | Garantir integridade referencial. |
| RNF03 | Utilizar codificação utf8mb4. |
| RNF04 | Prever controle de acesso por usuário. |
| RNF05 | Proteger dados pessoais conforme a LGPD. |
| RNF06 | Prever rotinas de backup. |
| RNF07 | Organizar os dados para reduzir redundâncias. |
| RNF08 | Permitir consultas SQL. |
| RNF09 | Utilizar dados fictícios no ambiente acadêmico. |
| RNF10 | Possibilitar integração futura com aplicações web. |
| RNF11 | Permitir futuras análises com Power BI. |



---

### 1.1.9 Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | Cada registro deverá possuir uma identificação única. |
| RN02 | CPF e CNPJ não deverão ser repetidos quando informados nos respectivos cadastros. |
| RN03 | Cada agendamento deverá estar associado a paciente, funcionário e consultório existentes. |
| RN04 | O paciente do atendimento deverá corresponder ao paciente do agendamento relacionado. |
| RN05 | Os procedimentos executados deverão ser associados ao respectivo atendimento. |
| RN06 | Pagamentos concluídos deverão possuir valor não negativo e data de pagamento. |
| RN07 | Quantidades e valores dos itens de compra deverão ser positivos. |
| RN08 | O estoque mínimo deverá ser não negativo e o saldo não deverá ficar negativo. |
| RN09 | Uma movimentação não deverá possuir simultaneamente uma compra e uma produção como origem. |
| RN10 | A conclusão de uma manutenção não poderá anteceder o seu início. |
| RN11 | O encerramento de um ciclo de esterilização não poderá ocorrer antes do início. |
| RN12 | Equipamentos deverão possuir referências válidas aos consultórios e responsáveis cadastrados. |



---

### 1.1.10 Modelo Conceitual — DER

O Diagrama Entidade-Relacionamento foi elaborado utilizando o **brModelo Web**.

O modelo representa entidades, atributos e relacionamentos relacionados à operação odontológica.

#### Diagrama Conceitual

<p align="center">
  <img src="Modelos%20DER_%20MERMAIND/Modelo%20DER%20BrModel.jpg" alt="Modelo conceitual DER - Odontologia Sasaki" width="900">
</p>

**Arquivo original:**

[Visualizar o DER original (JPG)](Modelos%20DER_%20MERMAIND/Modelo%20DER%20BrModel.jpg)

> O PDF do DER não consta na estrutura de arquivos apresentada. Adicione-o antes de criar um link para PDF.

#### Revisão do DER

O DER recebido contempla entidades como:

- Cliente;
- Consultório;
- Consulta;
- Funcionário;
- Equipamentos;
- Manutenção;
- Produção;
- Estoque;
- Fornecedor.

Entretanto, o modelo SQL atualizado contém 20 tabelas.

Por isso, será necessário revisar o DER conceitual para representar integralmente o sistema implementado.

A revisão deverá contemplar:

- Relacionamentos;
- Cardinalidades;
- Identificadores;
- Entidades associativas;
- Compatibilidade com o modelo lógico;
- Correspondência com os requisitos levantados.



---

## 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

A conversão do modelo conceitual para o lógico consiste em transformar entidades e relacionamentos em tabelas e chaves.

### Entidades para Tabelas

Cada entidade relevante foi representada por uma tabela no banco.

Exemplos:

| Entidade | Tabela |
|---|---|
| Paciente | paciente |
| Funcionário | funcionario |
| Consultório | consultorio |
| Agendamento | agendamento |
| Atendimento | atendimento |
| Procedimento | procedimento |
| Equipamento | equipamento |
| Manutenção | manutencao |
| Material | material |
| Fornecedor | fornecedor |

### Atributos para Colunas

Os atributos foram convertidos em colunas com tipos de dados adequados.

| Tipo de dado | Utilização |
|---|---|
| BIGINT | Identificadores |
| VARCHAR | Textos |
| CHAR | Identificadores de tamanho fixo |
| DATE | Datas |
| DATETIME | Datas e horários |
| DECIMAL | Valores monetários |
| INT | Quantidades |
| TEXT | Descrições |
| ENUM | Valores de domínio controlado |

### Relacionamentos 1:N

Relacionamentos um-para-muitos foram implementados utilizando chaves estrangeiras.

Exemplo:

Um paciente pode possuir vários agendamentos.

```sql
FOREIGN KEY (id_paciente)
REFERENCES paciente(id_paciente)
```

### Relacionamentos N:N

Relacionamentos muitos-para-muitos foram implementados utilizando tabelas associativas.

Principais exemplos:

- atendimento_procedimento;
- plano_procedimento;
- item_compra;
- item_producao.

Essas tabelas permitem armazenar informações próprias das associações.

### Relacionamentos 1:1

A implementação atual não possui relacionamento exclusivamente 1:1 garantido formalmente por uma restrição UNIQUE.

### Generalização e Especialização

Não foi implementada uma estrutura formal de herança entre entidades.

---

## 1.3 Definição de Chaves Primárias e Estrangeiras

O banco de dados possui 20 tabelas e 31 relacionamentos por chaves estrangeiras.

| Tabela | Chave Primária | Chaves Estrangeiras |
|---|---|---|
| consultorio | id_consultorio | — |
| funcionario | id_funcionario | — |
| paciente | id_paciente | — |
| fornecedor | id_fornecedor | — |
| material | id_material | — |
| procedimento | id_procedimento | — |
| equipamento | id_equipamento | id_consultorio, id_responsavel |
| manutencao | id_manutencao | id_equipamento, id_funcionario |
| agendamento | id_agendamento | id_paciente, id_funcionario, id_consultorio |
| atendimento | id_atendimento | id_paciente, id_profissional, id_consultorio, id_agendamento |
| atendimento_procedimento | id | id_atendimento, id_procedimento |
| plano_tratamento | id_plano | id_paciente, id_profissional |
| plano_procedimento | id | id_plano, id_procedimento |
| pagamento | id_pagamento | id_atendimento |
| compra | id_compra | id_fornecedor, id_funcionario |
| item_compra | id | id_compra, id_material |
| producao | id_producao | id_responsavel |
| item_producao | id | id_producao, id_material |
| movimentacao_estoque | id_movimentacao | id_material, id_responsavel, id_compra, id_producao |
| esterilizacao | id_ciclo | id_equipamento, id_responsavel |

### Justificativa

As chaves primárias garantem a identificação individual de cada registro.

As chaves estrangeiras permitem relacionar informações armazenadas em diferentes tabelas.

Essa estrutura contribui para a integridade referencial e reduz a repetição desnecessária de dados.

---

## 1.4 Processo de Normalização

A normalização é utilizada para organizar os dados e reduzir redundâncias.

O projeto considera três formas normais.

### Primeira Forma Normal — 1FN

A 1FN determina que os campos devem armazenar valores atômicos.

Um atendimento pode possuir vários procedimentos.

Por esse motivo, os procedimentos não foram armazenados em uma única coluna.

Foi criada a tabela:

`atendimento_procedimento`

A mesma estratégia foi utilizada nas tabelas:

- item_compra;
- item_producao;
- plano_procedimento.

### Segunda Forma Normal — 2FN

A 2FN busca eliminar dependências parciais de chaves compostas.

O banco utiliza predominantemente chaves primárias simples.

Os dados específicos de cada entidade foram separados em suas respectivas tabelas.

>Por exemplo:
>As informações cadastrais de um material ficam na tabela `material`.
>As informações relacionadas à participação do material em uma compra ficam em `item_compra`.

### Terceira Forma Normal — 3FN

A 3FN busca eliminar dependências transitivas.

>Por exemplo:
>O nome e o telefone de um paciente são armazenados na tabela `paciente`.
>A tabela `atendimento` utiliza uma chave estrangeira para identificar o paciente.
>Isso evita repetir os dados cadastrais em cada atendimento.



---

## 1.5 Justificativas Técnicas

### Utilização de MySQL

O MySQL foi escolhido por ser um sistema gerenciador de banco de dados relacional amplamente utilizado.

O projeto utiliza recursos como:

- PRIMARY KEY;
- FOREIGN KEY;
- NOT NULL;
- UNIQUE;
- CHECK;
- DEFAULT;
- AUTO_INCREMENT.

### Chaves Primárias

Foram utilizados identificadores numéricos para representar os registros.

Exemplo:

```sql
id_paciente BIGINT AUTO_INCREMENT PRIMARY KEY
```

Essa abordagem permite identificar registros independentemente de informações pessoais.

### Chaves Estrangeiras

As chaves estrangeiras implementam os relacionamentos entre tabelas.

Exemplo:

```sql
FOREIGN KEY (id_paciente)
REFERENCES paciente(id_paciente)
```

### Restrições de Integridade

| Restrição | Finalidade |
|---|---|
| PRIMARY KEY | Identificação única |
| FOREIGN KEY | Relacionamento entre tabelas |
| NOT NULL | Obrigatoriedade |
| UNIQUE | Unicidade |
| CHECK | Validação de valores |
| DEFAULT | Valor padrão |

### Rastreabilidade das Restrições

| Regra | Mecanismo |
|---|---|
| RN01 | PRIMARY KEY |
| RN02 | UNIQUE |
| RN03 | FOREIGN KEY |
| RN04 | Auditoria A01 |
| RN05 | Auditoria A02 |
| RN06 | CHECK e auditoria A07 |
| RN07 | CHECK e auditoria A06 |
| RN08 | CHECK e auditoria A03 |
| RN09 | Auditoria A04 |
| RN10 | Auditoria A08 |
| RN11 | Auditoria A05 |
| RN12 | FOREIGN KEY |

Algumas regras ainda dependem de restrições adicionais na aplicação ou no próprio banco.

---

## 1.6 Proposta de Arquitetura Analítica para BI e IA

O banco pode ser utilizado como fonte de informações para ferramentas de Business Intelligence.

### Indicadores Gerenciais

| KPI | Indicador | Consulta |
|---|---|---|
| K01 | Agendamentos por mês | G01 |
| K02 | Taxa de cancelamento | G02 |
| K03 | Atendimentos por profissional | G03 |
| K04 | Pagamentos por período | G04 |
| K05 | Valor médio por atendimento | G05 |
| K06 | Materiais abaixo do estoque mínimo | G06 |
| K07 | Custos de manutenção | G07 |
| K08 | Taxa de reprovação de esterilização | G08 |
| K09 | Compras por fornecedor | G09 |
| K10 | Planos de tratamento por situação | G10 |
| K11 | Consumo de materiais | G11 |

### Fórmulas dos Indicadores

**K01 — Volume de agendamentos**

Quantidade de agendamentos registrados por mês.

**K02 — Taxa de cancelamento**

```text
Agendamentos cancelados / Total de agendamentos × 100
```

**K03 — Atendimentos por profissional**

Quantidade de atendimentos associados a cada profissional por mês.

**K04 — Pagamentos por período**

```text
Soma dos valores dos pagamentos registrados no período
```

**K05 — Valor médio por atendimento**

```text
Total dos pagamentos / Quantidade de atendimentos com pagamento
```

**K06 — Estoque crítico**

Quantidade de materiais cujo saldo esteja menor ou igual ao estoque mínimo.

**K07 — Custos de manutenção**

```text
Soma dos custos das manutenções por equipamento
```

**K08 — Taxa de reprovação de esterilização**

```text
Ciclos reprovados / Total de ciclos × 100
```

**K09 — Compras por fornecedor**

Soma dos valores adquiridos por fornecedor.

**K10 — Planos de tratamento**

Quantidade de planos agrupados por situação.

**K11 — Consumo de materiais**

Soma das quantidades de saída por material e período.

### Rastreabilidade

| Problema | Tabelas | Consultas |
|---|---|---|
| P1 — Agendamentos | agendamento, paciente, funcionario | G01, G02 |
| P2 — Atendimentos | atendimento, procedimento, plano_tratamento | G03, G10 |
| P3 — Financeiro | pagamento, atendimento | G04, G05 |
| P4 — Estoque | material, compra, movimentacao_estoque | G06, G09, G11 |
| P5 — Manutenção | equipamento, manutencao | G07 |
| P6 — Esterilização | esterilizacao | G08 |

### Aplicações de BI

A estrutura poderá ser utilizada para desenvolver dashboards contendo:

- Agendamentos mensais;
- Taxa de cancelamento;
- Quantidade de atendimentos;
- Valores financeiros;
- Materiais abaixo do mínimo;
- Consumo de materiais;
- Custos com manutenção;
- Resultados de esterilização.

### Aplicações Futuras de Inteligência Artificial

O banco também poderá apoiar:

- Previsão de demanda de atendimentos;
- Previsão de consumo de materiais;
- Identificação de padrões de manutenção;
- Análise de tendências;
- Identificação de registros anômalos.

Essas aplicações dependem de dados históricos suficientes, validação técnica e proteção de dados pessoais.

---

# 2. MODELO LÓGICO RELACIONAL

O modelo lógico representa a estrutura relacional do sistema.

O banco possui:

- 20 tabelas;
- 20 chaves primárias;
- 31 chaves estrangeiras;
- Relacionamentos 1:N;
- Relacionamentos N:N por tabelas associativas.

### Modelo Lógico

<p align="center">
  <img src="Modelos%20DER_%20MERMAIND/modelo_logico_odontologia_sasaki_page-1.png.jpg" alt="Modelo lógico relacional - Odontologia Sasaki" width="900">
</p>

O modelo deverá apresentar:

- Nome das tabelas;
- Atributos;
- Tipos de dados;
- Chaves primárias;
- Chaves estrangeiras;
- Cardinalidades.

### Dicionário de Dados

O dicionário completo foi desenvolvido em HTML.

O documento contém:

- Descrição das tabelas;
- Campos;
- Tipos de dados;
- Restrições;
- Obrigatoriedade;
- Valores padrão;
- Relacionamentos.

[📖 Visualizar Dicionário de Dados](Dicionario%20de%20banco%20de%20dados/dicionario_de_dados_odontologia_sasaki_atualizado.html)

---

# 3. SCRIPT SQL COMPLETO

O banco foi desenvolvido utilizando MySQL 8.

### Informações Técnicas

| Característica | Valor |
|---|---|
| Banco | odontologia_sasaki_atualizado |
| SGBD | MySQL 8 |
| Engine | InnoDB |
| Charset | utf8mb4 |
| Tabelas | 20 |
| Relacionamentos FK | 31 |
| Registros fictícios | 456 |
| Consultas gerenciais | 11 |
| Consultas de auditoria | 8 |

### Arquivo SQL

[🗄️ Visualizar Script SQL](Banco%20de%20dados/odontologia_sasaki_entrega2_completo.sql)

### Comandos Utilizados

O script contempla:

- CREATE DATABASE;
- CREATE TABLE;
- PRIMARY KEY;
- FOREIGN KEY;
- CHECK;
- UNIQUE;
- INSERT INTO;
- SELECT;
- JOIN;
- UPDATE;
- DELETE.

### Consultas Gerenciais

| Código | Objetivo |
|---|---|
| G01 | Consultar agendamentos por período |
| G02 | Calcular taxa de cancelamento |
| G03 | Consultar atendimentos por profissional |
| G04 | Consultar pagamentos por período |
| G05 | Calcular valor médio por atendimento |
| G06 | Identificar materiais abaixo do mínimo |
| G07 | Consultar manutenções e custos |
| G08 | Analisar esterilizações |
| G09 | Consultar compras por fornecedor |
| G10 | Analisar planos de tratamento |
| G11 | Consultar consumo de materiais |

### Consultas de Auditoria

| Código | Regra verificada |
|---|---|
| A01 | RN04 — Paciente divergente |
| A02 | RN05 — Atendimento sem procedimentos |
| A03 | RN08 — Estoque negativo |
| A04 | RN09 — Origem de movimentação incompatível |
| A05 | RN11 — Datas de esterilização |
| A06 | RN07 — Quantidades de compras |
| A07 | RN06 — Pagamentos concluídos |
| A08 | RN10 — Datas de manutenção |

### Execução do Banco

Para executar o banco:

1. Abrir MySQL Workbench.
2. Conectar ao servidor.
3. Abrir o script SQL.
4. Executar os comandos.
5. Conferir as tabelas.
6. Consultar os registros.
7. Executar as consultas gerenciais.
8. Executar as auditorias.

**Status:** execução integral em MySQL ainda precisa ser comprovada.

---

# 4. MASSA DE DADOS

O projeto contém uma massa fictícia de dados organizada em 20 tabelas.

### Quantidade de Registros

| Tabela | Registros |
|---|---:|
| consultorio | 6 |
| funcionario | 10 |
| paciente | 20 |
| fornecedor | 5 |
| material | 15 |
| procedimento | 10 |
| equipamento | 10 |
| manutencao | 10 |
| agendamento | 70 |
| atendimento | 50 |
| atendimento_procedimento | 83 |
| plano_tratamento | 8 |
| plano_procedimento | 12 |
| pagamento | 50 |
| compra | 6 |
| item_compra | 12 |
| producao | 8 |
| item_producao | 11 |
| movimentacao_estoque | 30 |
| esterilizacao | 30 |
| **TOTAL** | **456** |

### Justificativa

A massa de dados foi elaborada para representar um cenário acadêmico de aproximadamente dois meses de operação.

Foram considerados:

- 35 agendamentos por mês;
- 25 atendimentos por mês;
- 10 funcionários;
- 6 consultórios;
- 20 pacientes na amostra;
- 10 equipamentos;
- 15 materiais.



### Variedade de Dados

A massa contempla registros destinados a representar:

- Diferentes situações de agendamento;
- Atendimentos;
- Procedimentos;
- Pagamentos;
- Compras;
- Estoque;
- Produção;
- Manutenções;
- Esterilizações.


---

# 5. REPOSITÓRIO GITHUB

O projeto está organizado em um repositório GitHub, com os arquivos distribuídos em pastas temáticas.

### Estrutura

```text
Entrega-2--MBD/
├── README.md
├── Banco de dados/
│   └── odontologia_sasaki_entrega2_completo.sql
├── Dicionario de banco de dados/
│   └── dicionario_de_dados_odontologia_sasaki_atualizado.html
├── Evidencias da entrevista/
│   ├── Foto com o doutor marcelo.png
│   └── PORTA CLÍNICA.png
└── Modelos DER_ MERMAIND/
    ├── Modelo DER BrModel.jpg
    └── modelo_logico_odontologia_sasaki_page-1.png
```

### Documentação

O repositório reúne os seguintes artefatos:

- Relatório técnico;
- Script SQL;
- Dicionário de dados;
- Modelo conceitual;
- Modelo lógico;
- Massa de dados;
- Levantamento de requisitos;
- Evidências da organização;
- Apresentação final.
---

# 6. USO DE INTELIGÊNCIA ARTIFICIAL

Durante o desenvolvimento do projeto foi utilizado o ChatGPT, desenvolvido pela OpenAI.

A ferramenta auxiliou na elaboração e organização de diferentes artefatos.

### Ferramenta Utilizada

**Nome:** ChatGPT

**Desenvolvedor:** OpenAI

**Finalidade:** Apoio técnico e documental.

### Etapas com Apoio de IA

- Modelagem do banco de dados;
- Análise do DER;
- Criação de scripts SQL;
- Organização da massa fictícia;
- Elaboração do dicionário;
- Revisão da normalização;
- Elaboração de requisitos;
- Criação de consultas;
- Organização do README.

### Prompt 01 — Atualização do Banco

**Prompt:**

> Com base na planilha crie um novo banco de dados, com a ajuda do DER e atualize o nosso dicionário de dados.

**Motivação:**

Adequar o banco às informações existentes na planilha.

**Resultado:**

Foi preparada uma estrutura relacional com 20 tabelas e 31 chaves estrangeiras.

Também foi elaborado um novo dicionário de dados em HTML.

**Limitação:**

A implementação precisa de validação integral no MySQL e revisão de compatibilidade com o DER.

---

### Prompt 02 — Documentação

**Prompt:**

> Agora organize o readme, com todas as informações que precisa Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final.

**Motivação:**

Organizar o relatório técnico conforme as orientações da disciplina.

**Resultado:**

Foram elaboradas seções referentes a:

- Organização;
- Requisitos;
- Regras de negócio;
- Normalização;
- Chaves;
- SQL;
- Indicadores;
- Auditorias;
- Documentação.

---

### Reflexão Crítica

A utilização de inteligência artificial contribuiu para a organização e estruturação do trabalho.

Entretanto, foram identificadas limitações.

Entre elas:

- Possibilidade de inconsistências entre DER e SQL;
- Necessidade de validar as regras de negócio;
- Necessidade de testar o SQL;
- Possibilidade de sugestões inadequadas de normalização;
- Necessidade de verificar informações da clínica;
- Necessidade de distinguir dados fictícios de dados reais.

A ferramenta foi utilizada como apoio ao desenvolvimento e não substitui a validação técnica e o levantamento presencial.

### Fontes Utilizadas

Foram considerados:

- Planilha Excel;
- DER em Mermaid;
- DER em brModelo;
- Script SQL;
- Dicionário de dados;
- Enunciado da atividade;
- Fotografias enviadas pelo grupo.

---

# 8. CONCLUSÃO

O projeto Odontologia Sasaki foi desenvolvido com o objetivo de estruturar um banco de dados relacional para integrar informações relacionadas ao funcionamento de uma clínica odontológica.

A implementação atual possui:

- 20 tabelas;
- 31 relacionamentos por chaves estrangeiras;
- 456 registros fictícios;
- 11 consultas gerenciais;
- 8 consultas de auditoria.

A estrutura contempla processos relacionados a pacientes, funcionários, agendamentos, atendimentos, procedimentos, pagamentos, compras, estoque, equipamentos, manutenção e esterilização.

Durante o desenvolvimento foram aplicados conceitos de modelagem conceitual, modelagem lógica, integridade referencial e normalização.

Também foram propostas consultas gerenciais capazes de apoiar futuras análises administrativas.

O sistema poderá servir como base para o desenvolvimento de aplicações web e dashboards em ferramentas como o Power BI.

Como evolução futura, poderá receber novos módulos de gestão e funcionalidades analíticas.

A conclusão acadêmica do projeto depende da validação das informações da organização, revisão dos diagramas e execução integral do banco em MySQL.

---

# 🛠️ TECNOLOGIAS UTILIZADAS

| Tecnologia | Utilização |
|---|---|
| MySQL 8 | Banco de dados |
| SQL | Criação e manipulação de dados |
| brModelo Web | Modelagem conceitual |
| Mermaid | Diagrama auxiliar |
| HTML | Dicionário de dados |
| Excel | Massa de dados |
| GitHub | Versionamento |
| Markdown | Documentação |
| ChatGPT | Apoio técnico |

---

## 🦷 ODONTOLOGIA SASAKI

**Sistema de Gestão de Informações Odontológicas**

**Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final**

**Novembro de 2026**
