![Banking Fraud Confluent](docs/assets/banking-fraud-confluent.png)

# Banking Fraud Confluent

## Objetivo

O projeto implementa, em etapas, um pipeline de detecção de fraudes bancárias.
A etapa atual prepara de forma reproduzível a origem de dados sintéticos no
PostgreSQL/Neon.

## Arquitetura

O pipeline em implementação leva os dados do PostgreSQL/Neon ao Confluent Cloud
por CDC. A arquitetura define contratos Avro para os eventos e usa Flink SQL
para enriquecer as transações com dados das contas e identificar três
transações no mesmo cartão em até 60 segundos. Os alertas seguem para consumo.

## Tecnologias

- Python
- Poetry
- PostgreSQL
- Neon

## Pré-requisitos

Para preparar e executar o projeto, a máquina deve ter:

- Ubuntu ou Debian com Bash
- Usuário com permissão para executar `sudo`
- Acesso à internet
- Git
- `curl` e o pacote `ca-certificates`
- Python 3 e suporte a ambientes virtuais, usados para instalar e executar o
  Poetry
- `pyenv`, usado para instalar e selecionar o Python do projeto
- Ferramentas de compilação e bibliotecas necessárias para o `pyenv` construir
  o Python
- Python 3.12.3, versão do ambiente de desenvolvimento de referência
- Poetry 2.5.1
- Cliente `psql` do PostgreSQL para carregar os CSVs locais
- Conta no Neon para criar o projeto e configurar o banco

Para reproduzir a partir do zero, clone este repositório pela opção **Code**
do GitHub, entre na pasta clonada e execute os passos seguintes a partir da
raiz do projeto. Os comandos neste README devem ser executados pelo leitor;
o arquivo não executa o pipeline sozinho.

As ferramentas locais e o Python 3.12.3 são instalados pelos comandos a seguir.

## Instalação das ferramentas

Atualizar o índice de pacotes e instalar Git, `curl` e um Python de sistema para
o instalador do Poetry:

```bash
sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  git \
  python3 \
  python3-venv
```

O Python de sistema será usado pelo instalador e pelo ambiente isolado do
Poetry, não como interpretador do projeto.

Instalar o `pyenv`:

```bash
curl -fsSL https://pyenv.run | bash
~/.pyenv/bin/pyenv init --install
```

Fechar e abrir o terminal novamente para carregar a configuração gravada pelo
comando anterior. Depois, instalar as dependências necessárias para compilar o
Python:

```bash
pyenv install-prerequisites
```

Instalar a versão do Poetry adotada pelo projeto:

```bash
curl -sSL https://install.python-poetry.org | python3 - --version 2.5.1
export PATH="$HOME/.local/bin:$PATH"
```

Se `$HOME/.local/bin` ainda não fizer parte do `PATH` permanente do usuário,
adicionar a linha abaixo ao arquivo de inicialização do Bash, como `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Preparação do ambiente

Instalar a versão de Python adotada pelo ambiente de desenvolvimento:

```bash
pyenv install --skip-existing 3.12.3
```

Configurar o ambiente virtual dentro do projeto e selecionar explicitamente o
Python 3.12.3:

```bash
poetry config virtualenvs.in-project true
PYTHON_312_PATH="$(pyenv prefix 3.12.3)/bin/python"
test -x "$PYTHON_312_PATH"
poetry env use "$PYTHON_312_PATH"
```

Instalar as dependências:

```bash
poetry install
```

O projeto aceita a série Python 3.12 (`>=3.12,<3.13`); o ambiente de
desenvolvimento de referência usa a versão 3.12.3.

Instalar o cliente `psql` 18 para carregar os CSVs. Se a série 18 ainda não
estiver disponível no APT, o comando configura o repositório PostgreSQL:

```bash
if ! psql --version 2>/dev/null | grep -Eq '^psql \(PostgreSQL\) 18\.[0-9]+([[:space:]]|$)'; then
  sudo apt update
  sudo apt install -y postgresql-common ca-certificates
  sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
  sudo apt update
  sudo apt install -y postgresql-client-18
fi
```

## Dados de origem

Os dados de entrada são sintéticos e já estão versionados no clone; não é
necessário gerá-los nem baixá-los. Os arquivos são:

- `dataset/data/customers.csv`: 200 clientes
- `dataset/data/accounts.csv`: 240 contas
- `dataset/data/cards.csv`: 320 cartões
- `dataset/data/merchants.csv`: 60 estabelecimentos
- `dataset/data/transactions.csv`: 2000 transações

O relatório [quality_report.csv](evidencias/dataset-quality/quality_report.csv)
registra as cardinalidades, as chaves primárias distintas e zero referências
órfãs nos cinco conjuntos. Ele não deve ser carregado no PostgreSQL.

## Origem Neon/Postgres

O PostgreSQL no Neon é a origem das alterações para o fluxo de CDC. Nesta
etapa, prepare e valide o banco:

1. No Neon Console, crie um projeto `banking-fraud-confluent` com PostgreSQL
   18. Selecione a branch `main`, o compute `Primary` e o banco `neondb`.
   Se o banco não existir, crie-o com `neondb_owner` como proprietário.
2. Nas configurações do projeto, habilite **Logical Replication**.
3. No SQL Editor desse banco, execute
   [schema.sql](database/postgres/schema.sql), exceto a primeira linha
   `\set ON_ERROR_STOP on`, exclusiva do `psql`. Confirme o schema `payments`
   e as tabelas `customers`, `accounts`, `cards`, `merchants` e `transactions`.
4. Na raiz do repositório, copie `.env.example` para `.env` sem substituir um
   arquivo existente:

```bash
cp -n .env.example .env
```

Em **Connect**, copie a URL de `neondb_owner` para `DATABASE_URL` no `.env`
local. O arquivo contém segredos e não deve ser versionado.

5. Depois de salvar o `.env`, execute a carga uma única vez no banco novo:

```bash
source .env
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f database/postgres/load-data.sql
```

O `\copy` de [load-data.sql](database/postgres/load-data.sql) lê os CSVs
locais; por isso a carga usa `psql`. O script limpa e recarrega as tabelas:
não o execute novamente ao preparar CDC.

Ao final da carga, as tabelas `payments` devem conter 200 clientes, 240
contas, 320 cartões, 60 estabelecimentos e 2000 transações.

## Preparação para CDC

CDC permite levar alterações do PostgreSQL ao Confluent Cloud sem repetir a
carga completa dos CSVs. Prepare a origem nesta ordem:

1. Em **Postgres database → Roles** no Neon Console, crie `cdc_user`.
2. Em **Connect**, selecione essa role, a branch `main`, o banco `neondb` e a
   conexão direta, com **Connection pooling** desativado. Guarde a URL apenas
   em `CDC_DATABASE_URL` no `.env` local.
3. No SQL Editor de `neondb`, usando `neondb_owner`, execute
   [cdc-setup.sql](database/postgres/cdc-setup.sql), exceto a primeira linha
   `\set ON_ERROR_STOP on`, exclusiva do `psql`. O script prepara a
   publicação `payment_cdc_pub` para as cinco tabelas e define
   `REPLICA IDENTITY FULL` nelas.

A role criada pelo Neon Console herda `neon_superuser`, com privilégios
amplos; os grants do script não a restringem. A configuração do connector CDC
com a URL direta de `cdc_user` faz parte da etapa de ingestão.

## Status

O projeto está em implementação. O ambiente local está configurado, os dados
sintéticos estão versionados e carregados em `payments` no Neon/Postgres, e a
origem está preparada para CDC. Connector, replication slot, tópicos, contratos
Avro, Flink e consumo fazem parte das etapas seguintes.

## Governança de entregas

Cada entrega segue o fluxo `Issue → branch → commits → Pull Request → Merge Commit`.
