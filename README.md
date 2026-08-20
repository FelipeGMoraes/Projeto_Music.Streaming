# MusicStreaming Database

Banco de dados relacional completo simulando o backend de dados de uma plataforma de **music streaming 24/7**, desenvolvido com SQL Server 2019 e T-SQL.

O projeto cobre o ciclo completo de gestão de banco de dados em ambiente de produção: modelagem relacional, extração de insights de negócio, segurança enterprise e otimização de performance.

---

## Destaques técnicos

| Área | O que foi implementado |
|---|---|
| Modelagem | Diagrama ER com 8 tabelas: Songs, Artists, Albums, Genre, Users, Labels, Location e SongPlays |
| Consultas e relatórios | Queries analíticas para extração de insights de negócio via T-SQL |
| Segurança | TDE (Transparent Data Encryption), mascaramento dinâmico de dados (DDM), controle granular de permissões |
| Automatização | Backup automatizado com SQL Server Agent Jobs, stored procedures de auditoria e alertas |
| Performance | Particionamento de tabelas por data, compressão de dados, views, triggers e tabelas temporárias |

---

## Estrutura do projeto

```
Projeto_Music.Streaming/
├── analise-python/
│   ├── .env.example
│   ├── .gitignore
│   ├── requirements.txt
│   ├── conexao.py
│   ├── notebooks/
│   │   └── analise_exploratoria.ipynb
│   └── charts/
├── database/
│   ├── 01-modelagem/
│   │   ├── criacao-de-esquema.sql       # DDL: tabelas, PKs, FKs, constraints
│   │   ├── insercao-de-dados.sql        # DML: dados de exemplo
│   │   └── modelo-fisico.png            # Diagrama ER (modelo físico)
│   ├── 02-queries-relatorios/
│   │   └── consultas-e-relatorios.md    # Relatório em Markdown com queries analíticas
│   ├── 03-seguranca-automacao/
│   │   ├── procedures-var-tde.sql       # Stored procedures, TDE, auditoria
│   │   └── seguranca-agendamento.sql    # Usuários, permissões, DDM, jobs de backup
│   └── 04-performance-gestao/
│       ├── particionamento-compressao.sql  # Particionamento por data e compressão
│       └── temp-tables-views-triggers.sql  # Views, triggers, tabelas temporárias
├── docs/
│   ├── readme-docs.md                   # Documentação técnica detalhada
│   └── insights-negocios.md             # Perguntas de negócio respondidas com SQL
└── README.md
```

---

## Como executar

### 1. Banco de dados (SQL Server)

```sql
CREATE DATABASE [Music.Streaming];
GO
USE [Music.Streaming];
GO
-- Em seguida, execute na ordem:
-- database/01-modelagem/criacao-de-esquema.sql
-- database/01-modelagem/insercao-de-dados.sql
```

### 2. Consultas e relatórios

Relatório em Markdown com explicações e blocos SQL:
`database/02-queries-relatorios/consultas-e-relatorios.md`

**3. Segurança e automação**
```sql
-- Criptografia TDE, procedures e auditoria
database/03-seguranca-automacao/procedures-var-tde.sql

-- Usuários, permissões, mascaramento e backup automatizado
database/03-seguranca-automacao/seguranca-agendamento.sql
```

**4. Performance e gestão avançada**
```sql
-- Particionamento por data e compressão de dados
database/04-performance-gestao/particionamento-compressao.sql

-- Views, triggers e tabelas temporárias
database/04-performance-gestao/temp-tables-views-triggers.sql
```

---

## Exemplos de uso

**Top 10 músicas mais tocadas:**
```sql
SELECT TOP 10 TituloMusica, TotalReproducoes
FROM #ContagemReproducoesPorMusica
ORDER BY TotalReproducoes DESC;
```

**Auditoria de jobs de backup:**
```sql
EXEC ListJobsAndSchedules
    @JobName    = 'BackupJob',
    @DataInicial = '2024-01-01',
    @DataFinal   = '2024-12-31';
```

**Visualização de dados mascarados (DDM):**
```sql
SELECT * FROM dbo.UserDM;
```

---

## Diagrama ER

[![Modelo Físico](database/01-modelagem/modelo-fisico.png)](database/01-modelagem/modelo-fisico.png)

> Clique na imagem para visualizar em tamanho completo.

---

## Boas práticas adotadas

- **Senhas:** nunca versionadas nos scripts — use os placeholders e substitua em produção
- **Backup:** certificado e chave mestra do TDE devem ser exportados e guardados com segurança
- **Permissões:** princípio do menor privilégio — cada usuário recebe apenas o acesso necessário
- **Auditoria:** triggers e logs rastreiam alterações em dados sensíveis
- **Performance:** monitoramento recomendado com `DBCC CHECKDB`, análise periódica de índices e partições
- **Documentação:** todos os scripts contêm comentários explicando cada etapa

---

## Tecnologias utilizadas

![SQL Server](https://img.shields.io/badge/SQL%20Server-2019-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-linguagem-0078D4?style=flat)
![SSMS](https://img.shields.io/badge/SSMS-ferramenta-217346?style=flat)

---

## Equipe

Projeto desenvolvido em equipe de 4 pessoas como trabalho prático da
**Academia Database & Data Intelligence — Rumos**.

| Membro | Responsabilidade principal |
|---|---|
| Felipe Guimarães Moraes | Modelagem ER, queries e relatórios, views, triggers e stored procedures |
| + 3 colaboradores | Desenvolvimento conjunto do projeto |

---

## Documentação completa

Consulte a [documentação técnica](docs/readme-docs.md) para o índice de cada script.

Para perguntas de negócio respondidas com SQL, veja [insights de negócio](docs/insights-negocios.md).

---

## Extensão individual

Após a conclusão do trabalho em grupo na Rumos, **Felipe Guimarães Moraes** adicionou uma camada de análise de dados:

- Perguntas de negócio e queries em [docs/insights-negocios.md](docs/insights-negocios.md)
- Análise em Python (Pandas) em [analise-python/](analise-python/README.md)

Essa pasta **não faz parte da entrega original da equipe**. O restante do repositório (`database/` e este README) corresponde ao projeto acadêmico em grupo.