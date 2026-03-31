CREATE INDEX idx_Atleta ON Atleta(idAtleta);

CREATE INDEX idx_Equipa ON Equipa(nome);

CREATE INDEX idx_Modalidade ON Modalidade(nome);

CREATE INDEX idx_Evento_nome ON Evento(nome);
CREATE INDEX idx_Evento_tipo ON Evento(tipo);
CREATE INDEX idx_Evento_dataEvento ON Evento(dataEvento);

CREATE INDEX idx_Contacto ON Contacto(email);

SHOW INDEX FROM Atleta;
SHOW INDEX FROM Equipa;
SHOW INDEX FROM Modalidade;
SHOW INDEX FROM Evento;
SHOW INDEX FROM Contacto;
