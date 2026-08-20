import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
import urllib

# Carrega as variáveis do arquivo .env para a memória
load_dotenv()

def criar_engine_sql():
    #Lê as variáveis de ambiente e cria a conexão com o SQL Server.
    server = os.getenv('DB_SERVER')
    database = os.getenv('DB_DATABASE')
    
    # Se você usa usuário/senha, descomente as duas linhas abaixo e a string com UID/PWD
    # user = os.getenv('DB_USER')
    # password = os.getenv('DB_PASSWORD')
    
    # Montando a string de conexão para Autenticação do Windows (Trusted_Connection)
    # Se for usar usuário e senha, mude 'Trusted_Connection=yes' para 'UID={user};PWD={password}'
    params = urllib.parse.quote_plus(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"Trusted_Connection=yes;"
    )
    
    # Cria a engine de conexão do SQLAlchemy
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
    return engine

def obter_dados(query):
    #Recebe uma query SQL, conecta no banco e retorna um DataFrame do pandas.
    engine = criar_engine_sql()
    try:
        # O pandas usa a engine para rodar a query e já converte o resultado em DataFrame
        df = pd.read_sql(query, con=engine)
        return df
    except Exception as e:
        print(f"Erro ao buscar dados: {e}")
        return None

# --- Área de Teste Rápido ---
if __name__ == "__main__":
    print("Testando conexão...")
    query_teste = "SELECT TOP 5 * FROM Songs;"
    df_teste = obter_dados(query_teste)
    
    if df_teste is not None:
        print("Conexão bem-sucedida! Aqui estão as primeiras linhas:")
        print(df_teste)