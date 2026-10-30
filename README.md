![Banking Fraud Confluent](docs/assets/banking-fraud-confluent.png)

# Banking Fraud Confluent

## Objetivo

O projeto inicia pela preparação reproduzível da origem de dados sintéticos no
PostgreSQL/Neon.

## Arquitetura

O pipeline previsto levará os dados do PostgreSQL/Neon ao Confluent Cloud por
CDC. Os eventos terão contratos Avro; o Flink SQL enriquecerá as transações
com dados das contas e identificará três transações no mesmo cartão em até
60 segundos. Os alertas seguirão para consumo.

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
Python e confirmar o `pyenv`:

```bash
pyenv install-prerequisites
pyenv --version
```

Instalar a versão do Poetry adotada pelo projeto:

```bash
curl -sSL https://install.python-poetry.org | python3 - --version 2.5.1
export PATH="$HOME/.local/bin:$PATH"
poetry --version | grep -Fx 'Poetry (version 2.5.1)'
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

Validar a configuração:

```bash
poetry check
poetry run python --version
```

A versão exibida pelo último comando deve ser `Python 3.12.3`. O projeto aceita
a série Python 3.12 (`>=3.12,<3.13`), mas o ambiente de desenvolvimento de
referência usa a versão 3.12.3.

## Status

Ambiente local configurado. A preparação dos dados sintéticos, a criação e a
carga do banco PostgreSQL/Neon serão realizadas em etapas posteriores.

## Governança de entregas

Cada entrega segue o fluxo `Issue → branch → commits → Pull Request → Merge Commit`.
