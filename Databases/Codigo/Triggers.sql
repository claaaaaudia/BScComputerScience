
#DROP TRIGGER atualizaResultadoEmTesteDopingPositivo;

DELIMITER $$

CREATE TRIGGER atualizaResultadoEmTesteDopingPositivo
	AFTER INSERT ON TesteDoping
    FOR EACH ROW
BEGIN
	IF NEW.resultado = 1 AND NEW.tipo != 'Tecnológico' THEN
		UPDATE Resultado
        SET posicao = 'EXPULSO',
			detalhes = CONCAT('Atleta expulso por resultado positivo em teste de doping realizado em ', 
                              DATE_FORMAT(NEW.dataRealizado, '%Y-%m-%d %H:%i:%s'))
        WHERE idAtleta = (
            SELECT idAtleta
            FROM PASSAPORTEBIOLOGICO
            WHERE idPassaporteBiologico = NEW.idPassaporteBiologico
            );
		UPDATE Podio
        SET descricao = 'EXPULSO'
        WHERE idAtleta = (
            SELECT idAtleta
            FROM PASSAPORTEBIOLOGICO
            WHERE idPassaporteBiologico = NEW.idPassaporteBiologico
            );
	END IF;
END $$

DELIMITER ;

-- DROP TRIGGER adicionaPodioEmResultado;

DELIMITER $$

CREATE TRIGGER adicionaPodioEmResultado
	AFTER INSERT ON Resultado
    FOR EACH ROW
BEGIN
	DECLARE pos TEXT;
	IF NEW.Posicao = '1' THEN
		SET pos = 'Ouro';
	ELSEIF NEW.Posicao = '2' THEN
		SET pos = 'Prata';
	ELSEIF NEW.Posicao = '3' THEN
		SET pos = 'Bronze';
	ELSE
		SET pos = 'None';
    END IF;
    IF pos != 'None' THEN
		INSERT INTO Podio (descricao,idAtleta)
        VALUES (pos,NEW.idAtleta);
	END IF;
END $$

DELIMITER ;

-- INSERT INTO Resultado (posicao, detalhes, idEvento, idAtleta)
-- VALUES ('6', 'Victory', 1, 1);