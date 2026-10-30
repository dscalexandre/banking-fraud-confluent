# ADR-001 — Adoção do Poetry para gerenciamento do projeto

**Status:** Aceita
**Data da decisão:** 30/10/2026
**Responsável:** Alexandre Rodrigues
**Rastreabilidade:** Issue #3

## Contexto

O projeto necessita de uma ferramenta para padronizar o gerenciamento de
dependências, ambientes virtuais, metadados e a execução de comandos locais.
A solução deve manter instalações reproduzíveis e centralizar a configuração
do projeto Python.

## Direcionadores da decisão

- suporte ao intervalo de versões Python adotado pelo projeto;
- execução consistente no ambiente local;
- baixo custo operacional para manutenção do ambiente.

## Alternativas consideradas

### Poetry

Atende aos direcionadores de instalação reproduzível e de uma interface única
para instalação e execução.

### Conda

É adequado para ambientes científicos e dependências não Python, mas adiciona
um modelo de ambiente e empacotamento mais amplo do que o necessário neste
incremento.

### pip com venv

Utiliza ferramentas nativas do ecossistema Python, porém exige mecanismos
adicionais e maior controle manual para lock, grupos de dependências e execução
padronizada.

### Pipenv

Oferece gerenciamento de dependências e ambiente virtual, mas é menos alinhado
à estratégia do projeto de centralizar metadados, build e configuração de
ferramentas no `pyproject.toml`.

## Decisão

O projeto adotará o Poetry para:

- gerenciar dependências do projeto;
- criar e manter o ambiente virtual local;
- gerenciar os metadados do projeto;
- padronizar a execução de comandos locais.

O ambiente virtual será criado dentro do diretório do projeto. O
`pyproject.toml` e o `poetry.lock` serão versionados e deverão permanecer
sincronizados.

## Consequências

### Benefícios

- configuração centralizada em `pyproject.toml`;
- instalações reproduzíveis;
- integração consistente com ferramentas de desenvolvimento.

### Custos e riscos

- necessidade de instalação prévia do Poetry;
- curva de aprendizado para colaboradores acostumados apenas com `pip`;
- necessidade de manter o `poetry.lock` sincronizado com o `pyproject.toml`;
- dependência operacional de uma ferramenta adicional no ambiente local.

### Ações de acompanhamento

- documentar a versão suportada e a instalação do Poetry no `README.md`;
- validar `pyproject.toml` e `poetry.lock` antes da publicação;
- executar comandos do projeto por meio de `poetry run`;
- revisar esta decisão se novos requisitos técnicos invalidarem seus
  direcionadores.

## Revisão e substituição

Esta ADR registra a decisão aceita e não deve ser alterada para esconder mudanças
posteriores de direção. Caso outra ferramenta seja adotada, uma nova ADR deverá
indicar que substitui a ADR-001 e explicar os novos contexto e critérios.
