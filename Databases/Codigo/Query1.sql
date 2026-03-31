-- Querry: Deve ser possÃ­vel visualizar cada atleta e equipa

SELECT 
    Atleta.idAtleta AS id_atleta,
    Atleta.nome AS nome_atleta, 
    Atleta.peso AS peso_atleta, 
    Atleta.altura AS altura_atleta, 
    Atleta.idade AS idade, 
    Equipa.idEquipa AS id_equipa, 
    Equipa.nome AS nome_equipa 
FROM 
    Atleta      
LEFT JOIN 
    Equipa 
ON 
    Atleta.idEquipa = Equipa.idEquipa 
ORDER BY 
    Atleta.nome;