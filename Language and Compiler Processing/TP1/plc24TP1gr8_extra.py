import re

ficheiro = open("arq-son.txt", "r", encoding="utf-8")
content = ficheiro.read()  
data = re.split(r'\n', content) 
ficheiro.close()

#Calcular a percentagem de canções que têm pelo menos uma gravação "mp3", indicando o título dessas canções;
def alineaB(data):

    total = len(data) - 1
    mp3 = 0
    titulos = []

    for linha in data:
        if(re.search(r"\w+[-\w]*\.mp3", linha) != None):
            linha_separada = re.split(r'::', linha)
            if(re.match(r'[A-Z][\w|\s]*',linha_separada[2])):
                titulos.append(linha_separada[2])
            mp3 += 1
                
    percentagem = mp3/total * 100
    print(f'{percentagem}%')
    print(titulos)
    return 0

alineaB(data)
