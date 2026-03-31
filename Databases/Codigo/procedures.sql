
DELIMITER $$

DROP PROCEDURE IF EXISTS criarTesteDoping $$

CREATE PROCEDURE criarTesteDoping (
	IN p_data DATETIME,
	IN p_tipo ENUM("Sangue", "Urina", "Tecnológico"),
	IN p_resultado TINYINT,
	IN p_observacoes TEXT,
	IN p_idAtleta INT
)
BEGIN

DECLARE v_idPassaporteBiologico INT;

DECLARE mensagem VARCHAR(100);

SET v_idPassaporteBiologico = getIdPassaporteFromIdAtleta(p_idAtleta);

IF v_idPassaporteBiologico = 0 THEN
    SET mensagem = 'Erro ao encontrar Passaporte Biológico do atleta.';
ELSE
	INSERT INTO TESTEDOPING (dataRealizado, tipo, resultado, observacoes, idPassaporteBiologico)
	VALUES (p_data, p_tipo, p_resultado, p_observacoes, v_idPassaporteBiologico);
    SET mensagem = CONCAT('Sucesso: Teste de doping criado com o ID ', LAST_INSERT_ID(), '.');
END IF;

SELECT mensagem;

END$$

DELIMITER ;

#CALL criarTesteDoping('2025-01-01 10:03:23', 'Urina', 1, 'Foi realizado um teste surpresa.', 23);

DELIMITER $$

DROP PROCEDURE IF EXISTS relatorioTesteDoping $$

CREATE PROCEDURE relatorioTesteDoping (
	IN p_idAtleta INT
)

BEGIN

DECLARE mensagem VARCHAR(100);
DECLARE v_idPassaporteBiologico INT;
DECLARE numeroTestes INT DEFAULT 0;
DECLARE numeroTestesPositivos INT DEFAULT 0;

SET v_idPassaporteBiologico = getIdPassaporteFromIdAtleta(p_idAtleta);

IF v_idPassaporteBiologico = 0 THEN
    SET mensagem = 'Erro ao encontrar Passaporte Biológico do atleta.';
ELSE
	SELECT COUNT(td.idTesteDoping) INTO numeroTestes
    FROM TesteDoping td
    WHERE td.idPassaporteBiologico = v_idPassaporteBiologico;
    
	SELECT COUNT(td.idTesteDoping) INTO numeroTestesPositivos
    FROM TesteDoping td
    WHERE td.idPassaporteBiologico = v_idPassaporteBiologico AND td.resultado = 1;
    
    SET mensagem = CONCAT('Encontrados ',numeroTestes, ' Testes de Doping realizados com ', numeroTestesPositivos, ' sendo positivos.');
END IF;

SELECT mensagem;

END $$

DELIMITER ;

#CALL relatorioTesteDoping(23);

DELIMITER $$

DROP PROCEDURE IF EXISTS estatisticaClassificacoes $$

CREATE PROCEDURE estatisticaClassificacoes (
IN p_edicao INT
)

BEGIN
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ouro DESC, prata DESC, bronze DESC, totalMedalhas DESC) AS ranking,
        nomeEquipa,
        ouro,
        prata,
        bronze,
        totalMedalhas
	FROM(
		SELECT
			E.nome AS nomeEquipa,
			SUM(CASE WHEN P.descricao = 'Ouro' THEN 1 ELSE 0 END) AS ouro,
			SUM(CASE WHEN P.descricao = 'Prata' THEN 1 ELSE 0 END) AS prata,
			SUM(CASE WHEN P.descricao = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
			SUM(CASE WHEN P.descricao != 'EXPULSO' THEN 1 ELSE 0 END) AS totalMedalhas
		FROM EQUIPA E
		LEFT JOIN ATLETA A ON E.idEquipa = A.idEquipa
		LEFT JOIN PODIO P ON A.idAtleta = P.idAtleta
		WHERE E.edicao = p_edicao
		GROUP BY E.idEquipa, E.nome
	) AS RelatorioClassificacoes
ORDER BY 
	ouro DESC,
	prata DESC,
	bronze DESC,
	totalMedalhas DESC;

END $$


DELIMITER ;

#CALL estatisticaClassificacoes(1);


DELIMITER $$

DROP PROCEDURE IF EXISTS criarModalidade $$

CREATE PROCEDURE criarModalidade (
	IN p_nome VARCHAR(45),
	IN p_edicao INT
)

BEGIN

	DECLARE mensagem VARCHAR(100);
	DECLARE v_dataInicio DATE;
    DECLARE v_dataFim DATE;
    
    SELECT dataInicio, dataFim
    INTO v_dataInicio, v_dataFim
    FROM jogosolimpicos
    WHERE edicao = p_edicao;
    
    IF CURDATE() < v_dataInicio OR CURDATE() > v_dataFim THEN
		INSERT INTO Modalidade (nome, edicao)
        VALUES (p_nome,p_edicao);
        SET mensagem = CONCAT('Sucesso: Modalidade criada com o ID ', LAST_INSERT_ID(), '.');
	ELSE
		SET mensagem = 'Erro: Modalidades não podem ser adicionadas enquanto os Jogos Olimpicos estiverem a decorrer.';
	END IF;
    SELECT mensagem;
END $$

DELIMITER ;

#CALL criarModalidade('Varrer',1);

DELIMITER $$

DROP PROCEDURE IF EXISTS criarEvento $$

CREATE PROCEDURE criarEvento (
	IN p_edicao INT,
	IN p_nome VARCHAR(45),
    IN p_tipo ENUM('Singular','Múltiplos'),
    IN p_regulamento TEXT,
    IN p_dataEvento DATETIME,
    IN p_idModalidade INT
)

BEGIN

	DECLARE mensagem VARCHAR(200);
	DECLARE v_dataInicio DATE;
    DECLARE v_dataFim DATE;
    
    SELECT dataInicio, dataFim
    INTO v_dataInicio, v_dataFim
    FROM jogosolimpicos
    WHERE edicao = p_edicao;
    
	IF CURDATE() NOT BETWEEN v_dataInicio AND v_dataFim THEN
		IF p_dataEvento BETWEEN v_dataInicio AND v_dataFim THEN
			INSERT INTO Evento (nome, tipo, regulamento, dataEvento, idModalidade)
			VALUES (p_nome, p_tipo, p_regulamento, p_dataEvento, p_idModalidade);
			SET mensagem = CONCAT('Sucesso: Evento criado com o ID ', LAST_INSERT_ID(), '.');
		ELSE
			SET mensagem = 'Erro: A data do evento não está dentro do período dos Jogos Olímpicos.';
		END IF;
	ELSE
		SET mensagem = 'Erro: Não é permitido criar eventos enquanto os Jogos Olímpicos estão a decorrer.';
	END IF;
    SELECT mensagem;
END $$

DELIMITER ;

#CALL criarEvento(1,'Ski pro','Singular','Nao matar','2026-02-07 10:03:23',1);
