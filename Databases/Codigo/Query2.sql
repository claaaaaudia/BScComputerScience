
SELECT 
    EV.idEvento, 
    EV.nome AS Nome_Evento, 
    EV.tipo AS Tipo_Evento, 
    EV.dataEvento AS Data_Evento, 
    M.nome AS Nome_Modalidade, 
    JO.edicao AS Edicao_Jogos
FROM 
    Evento EV
LEFT JOIN 
    Modalidade M ON EV.idModalidade = M.idModalidade
LEFT JOIN 
    JogosOlimpicos JO ON M.edicao = JO.edicao;




SELECT 
    A.idAtleta, 
    A.nome AS Nome_Atleta, 
    A.idade, 
    A.peso, 
    A.altura, 
    A.genero, 
    E.nome AS Nome_Equipa, 
    JO.edicao AS Edicao_Jogos, 
    C.email AS Contacto
FROM 
    Atleta A
LEFT JOIN 
    Equipa E ON A.idEquipa = E.idEquipa
LEFT JOIN 
    JogosOlimpicos JO ON A.edicao = JO.edicao
LEFT JOIN 
    Contacto C ON A.idContacto = C.idContacto;