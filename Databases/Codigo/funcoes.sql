
DELIMITER $$

CREATE FUNCTION getIdPassaporteFromIdAtleta(
p_idAtleta INT
)
RETURNS INT
READS SQL DATA
BEGIN
DECLARE v_idPassaporteBiologico INT;

SELECT idPassaporteBiologico
INTO v_idPassaporteBiologico
FROM PassaporteBiologico
WHERE idAtleta = p_idAtleta;

IF v_idPassaporteBiologico IS NULL THEN
	RETURN 0;
END IF;

RETURN v_idPassaporteBiologico;

END $$

DELIMITER ;