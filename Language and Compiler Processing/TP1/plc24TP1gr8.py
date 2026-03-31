import re

ficheiro = open("emd.csv", "r", encoding="utf-8")
content = ficheiro.read()  
data = re.split(r'\n', content) 
ficheiro.close()


# Formato da linha:
#_id,index,dataEMD,nome/primeiro,nome/ultimo,idade,género,morada,modalidade,clube,email,federado,aprovado

# Alínea a) Calcular as Idades extremas dos registos no dataset

def alinea_a(data):

    idadeMaior = 0
    idadeMenor = 100

    for i in range(1,len(data) - 1):
        linha_separada = re.split(r',', data[i]) # Em cada linha, o split transforma a linha numa lista de strings, separados pelas vírgula

        idade_atleta = int(linha_separada[5]) # Converte a string em inteiro
        if(idadeMaior < idade_atleta):
            idadeMaior = idade_atleta
        if(idadeMenor > idade_atleta):
            idadeMenor = idade_atleta

    return idadeMaior, idadeMenor

# Alínea b) Calcular a distribuição por Género no total

def alinea_b(data):

    quantidadeTotal = len(data) - 2 # Não consideramos a primeira linha, que serve apenas de indicação ao formato
    totalF = 0
    totalM = 0

    for linha in data:
        if(re.search(r',F,',linha)): # Search procura pela primeira ocorrência de ",F," (incluindo as vírgulas) que demonstra o Género feminino da linha atual
            totalF += 1
        if(re.search(r',M,',linha)): # Search procura pela primeira ocorrência de ",M," (incluindo as vírgulas) que demonstra o Género masculino da linha atual
            totalM += 1

    # Calcula a percentagem com duas casas decimais
    perF = round(totalF/quantidadeTotal * 100, 2) 
    perM = round(totalM/quantidadeTotal * 100, 2)

    return perF, perM

# Alínea c) Calcular a distribuição por Modalidade em cada ano e no total, devendo apresentar as Modalidades por ordem alfabética

def alinea_c(data):

    modPorAno = {} # Inicializa dicionário de modalidades por cada ano
    modalidades = [] # Inicializa lista que conterá todas as modalidades

    for i in range(1, len(data) - 1):
        date = re.search(r'(\d{4})\-(\d{2})\-(\d{2})',data[i]) # Search procura pela primeira ocorrência de uma data, expressa pela expressão regular escolhida, na linha atual
        if date:
            ano = int(date.group(1)) # Seleciona o ano em string e converte em inteiro

        linha_separada = re.split(',',data[i]) # Em cada linha, o split transforma a linha numa lista de strings, separados pelas vírgula
        modalidade = linha_separada[8] # Seleciona a modalidade, que vem sempre em índice 8

        if modalidade not in modalidades:
            modalidades.append(modalidade) # Se a modalidade ainda não está na lista de modalidades, é acrescentada
        modalidades.sort() # Ordenação alfabética

        if ano not in modPorAno:
            modPorAno[ano] = {modalidade: 1} # Inicializa o ano no dicionário de modalidades por cada ano, se ele ainda não lá estiver
        else:
            if modalidade not in modPorAno[ano]:
                modPorAno[ano].update({modalidade: 1}) # Inicializa a modalidade no dicionário de modalidades por cada ano, se ele ainda não lá estiver naquele ano
            else:
                modPorAno[ano][modalidade] += 1 # Se a modalidade já lá estiver, é incrementada
    
    # Distribuição por ano
    dist_ano = {} # Inicializa dicionário de distribuição por ano
    for ano in modPorAno:
        total_ano = 0
        frase = str(modPorAno[ano]) # Converte o dicionário em string
        totalRE = re.findall(r'[0-9]+',frase) # Findall coloca na lista totalRE todas as ocorrências de números na string
        for i in totalRE:
            total_ano += int(i) # Soma todos os números, sendo o valor final o número total de ocorrências de modalidades naquele ano

        dist_ano[ano] = [] 
        for modalidade in modalidades:
            if modalidade in modPorAno[ano]: 
                dist_ano[ano].append((modalidade, round(modPorAno[ano][modalidade] / total_ano * 100, 2))) # Cada ano terá uma lista de tuplos (Modalidade, Distribuição)

    # Distribuição no total
    dist_total = [] # Inicializa lista de distribuição total
    total = len(data) - 2
    for modalidade in modalidades:

        totalMod = 0

        for ano in modPorAno:
            if modalidade in modPorAno[ano]: 
                totalMod += modPorAno[ano][modalidade] # Soma todos os números, sendo o valor final o número total de ocorrências de modalidades no total
        
        dist_total.append((modalidade, round(totalMod / total * 100, 2))) # Lista de tuplos (Modalidade, Distribuição)

    return dist_total, dist_ano # Retorna um tuplo com os valores desejados

# Alínea d) Calcular a percentagem de Aptos e não aptos por ano

def alinea_d(data):

    aptoPorAno = {} # Inicializa dicionário de aptos por ano

    for i in range(1, len(data) - 1): # Para cada linha, 

        date = re.search(r'(\d{4})\-(\d{2})\-(\d{2})', data[i]) # Search procura pela primeira ocorrência de uma data, expressa pela expressão regular escolhida, na linha atual
        if date:
            ano = int(date.group(1)) # Seleciona o ano em string e converte em inteiro
        
        if ano not in aptoPorAno:
            aptoPorAno[ano] = {"apto": 0, "napto": 0} # Inicializa os contadores para cada ano
        
        if(re.search(r',true', data[i])): # Search procura pela primeira ocorrência da string ",true$" na linha atual, que indica que o atleta é apto
            aptoPorAno[ano]["apto"] += 1 # Incrementa o contador apto

        if(re.search(r',false', data[i])): # Search procura pela primeira ocorrência da string ",false$" na linha atual, que indica que o atleta não é apto
            aptoPorAno[ano]["napto"] += 1 # Incrementa o contador não apto

    dist_apto = {} 
    dist_napto = {}
    for ano in aptoPorAno:
        total_ano = 0
        frase = str(aptoPorAno[ano]) # Converte o dicionário de aptos por ano em string
        totalRE = re.findall(r'[0-9]+',frase) # Findall coloca na lista totalRE todas as ocorrências de números na string
        for i in totalRE:
            total_ano += int(i) # Soma todos os números, sendo o valor final o número total de atletas aptos naquele ano

        dist_apto.update({ano: round(aptoPorAno[ano]["apto"] / total_ano * 100, 2)}) # Calcula a percentagem de aptos
        dist_napto.update({ano: round(aptoPorAno[ano]["napto"] / total_ano * 100, 2)}) # Calcula a percentagem de não aptos

    return dist_apto, dist_napto

# Alínea e) Ajudar a normalizar as colunas do Nome, visto que o ficheiro original está inconsistente: quando o género é feminino
# cumpre-se o estabelecido no cabeçalho (primeiro o nome próprio e depois o apelido), mas quando o género é
# masculino essa ordem estabelecida no cabeçalho está trocada. Para isso, deve escrever num ficheiro de saída, em
# formato JSON, os pares de nomes masculinos que julga estar trocados (para que à posteriori o utilizador possa
# manualmente corrigir, se assim entender).

import json
def alinea_e(ficheiro, data):  

    nomes = [] # Inicializa lista de nomes

    for linha in data:
        if(re.search(r',M,', linha)): # Search encontra a primeira ocorrência de ",M," na linha, que indica que o atleta é do Género masculino
            separada = re.split(r',', linha) 
            nomes.append((separada[3], separada[4])) # Seleciona o primeiro e último nomes, que estão sempre nos índices 3 e 4
    
    ficheirojson = open(ficheiro, "w", encoding="utf-8") # Cria ficheiro json
    json.dump(nomes, ficheirojson, ensure_ascii=False, indent=4) # Escreve lá os nomes dos atletas masculinos
    ficheirojson.flush() # Limpa o buffer 


#Interpretação dos resultados

alinea_e("nomes.json", data)

# Crie uma página HTML (ficheiro ’index.html’) para apresentar os resultados do seu processador, no que respeita às primeiras 4 alíneas.

# Processa os dados e armazena os resultados
idadeMaior, idadeMenor = alinea_a(data)
perF, perM = alinea_b(data)
dist_total, dist_ano = alinea_c(data)
dist_apto, dist_napto = alinea_d(data)

# Gerar o conteúdo HTML
html_content = f"""
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultados EMD</title>
    <style>
        body {{ font-family: Arial, sans-serif; }}
        h1, h2, h3 {{ color: #2C3E50; }}
        table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
        table, th, td {{ border: 1px solid black; padding: 10px; text-align: left; }}
        th {{ background-color: #ffd6ff; color: black; }}
        tr:nth-child(even) {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <h1>Relatório dos Dados EMD</h1>

    <h2>Alínea A: Idades Extremas</h2>
    <p>A maior idade registrada é: <strong>{idadeMaior}</strong> anos</p>
    <p>A menor idade registrada é: <strong>{idadeMenor}</strong> anos</p>

    <h2>Alínea B: Distribuição por Género</h2>
    <p>Distribuição de Atletas do Género Feminino: <strong>{perF}%</strong></p>
    <p>Distribuição de Atletas do Género Masculino: <strong>{perM}%</strong></p>

    <h2>Alínea C: Distribuição das Modalidades</h2>
    <h3>Distribuição Total das Modalidades</h3>
    <table>
        <tr>
            <th>Modalidade</th>
            <th>Percentagem (%)</th>
        </tr>
        {"".join([f"<tr><td>{modalidade}</td><td>{percentagem}</td></tr>" for modalidade, percentagem in dist_total])}
    </table>

    <h3>Distribuição por Ano</h3>
    {"".join([f'''
    <h4>{ano}</h4>
    <table>
        <tr>
            <th>Modalidade</th>
            <th>Percentagem (%)</th>
        </tr>
        {"".join([f"<tr><td>{modalidade}</td><td>{percentagem}</td></tr>" for modalidade, percentagem in dist_ano[ano]])}
    </table>
    ''' for ano in dist_ano])}

    <h2>Alínea D: Percentagem de Atletas Aptos e Não Aptos por Ano</h2>
    <h3>Percentagem de Aptos</h3>
    <table>
        <tr>
            <th>Ano</th>
            <th>Percentagem de Aptos (%)</th>
        </tr>
        {"".join([f"<tr><td>{ano}</td><td>{percentagem}</td></tr>" for ano, percentagem in dist_apto.items()])}
    </table>

    <h3>Percentagem de Não Aptos</h3>
    <table>
        <tr>
            <th>Ano</th>
            <th>Percentagem de Não Aptos (%)</th>
        </tr>
        {"".join([f"<tr><td>{ano}</td><td>{percentagem}</td></tr>" for ano, percentagem in dist_napto.items()])}
    </table>
</body>
</html>
"""

# Escrever o conteúdo HTML no ficheiro 'index.html'
with open("index.html", "w", encoding="utf-8") as html_file:
    html_file.write(html_content)

print("Página HTML 'index.html' gerada com sucesso!")
