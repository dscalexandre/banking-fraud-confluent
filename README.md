![Banking Fraud Confluent](docs/assets/banking-fraud-confluent.png)

# Banking Fraud Confluent

## Objetivo

O projeto será iniciado pela preparação reproduzível da origem de dados
sintéticos no PostgreSQL/Neon.

## Arquitetura

O pipeline previsto levará os dados do PostgreSQL/Neon ao Confluent Cloud por
CDC. Os eventos terão contratos Avro; o Flink SQL enriquecerá as transações
com dados das contas e identificará três transações no mesmo cartão em até
60 segundos. Os alertas seguirão para consumo em etapas posteriores.

## Estado do projeto

Projeto em estruturação inicial. Nesta etapa, somente a base de governança e a
apresentação pública do repositório estão versionadas. A próxima entrega
adicionará os artefatos da origem de dados e as instruções para preparar o
ambiente local; os componentes produtivos ainda não estão implementados.
