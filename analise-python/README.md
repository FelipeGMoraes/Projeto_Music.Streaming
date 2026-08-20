# Análise em Python — extensão individual

Camada adicionada **depois** do trabalho em grupo da Rumos. Usa o banco `Music.Streaming` já modelado para análise exploratória com Pandas.

Não substitui os scripts SQL do projeto original; replica as perguntas de [docs/insights-negocios.md](../docs/insights-negocios.md).

## Pré-requisitos

- Python 3.10+
- SQL Server com o banco criado e populado (`database/01-modelagem/`)
- [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server)

## Configuração

```powershell
cd analise-python
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

Edite o `.env` com o servidor e o nome do banco. Teste:

```powershell
python conexao.py
```

Abra o notebook:

```powershell
jupyter notebook notebooks/analise_exploratoria.ipynb
```

## Arquivos

| Arquivo | Função |
|---|---|
| `conexao.py` | Conexão com SQL Server via SQLAlchemy |
| `notebooks/analise_exploratoria.ipynb` | Análise exploratória (SQL + Pandas) |
| `.env.example` | Modelo de variáveis (sem credenciais) |
