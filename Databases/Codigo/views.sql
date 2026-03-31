-- Listar todos os Atletas adicionando o nome da equipa

CREATE VIEW AtletasEquipasView AS
SELECT a.idAtleta, a.nome, a.idade, a.peso, a.altura, a.genero, a.idEquipa, e.nome AS 'Nome da Equipa', a.edicao
FROM 
	Atleta a
JOIN
	Equipa e
ON
	a.idEquipa = e.idEquipa AND a.edicao = e.edicao;
	
-- Listar todos os eventos em que os atletas estao inscritos

CREATE VIEW AtletasEventosView AS
SELECT a.idAtleta, a.nome AS 'Nome do Atleta', e.idEvento, e.nome AS 'Nome do Evento', e.tipo, e.regulamento, e.dataEvento, e.idModalidade
FROM
	Atleta a
JOIN
	Evento_has_atleta eha
ON
	a.idAtleta = eha.idAtleta
JOIN
	Evento e
ON
	eha.idEvento = e.idEvento;
    
-- Listar os atletas e os seus podios

CREATE VIEW AtletasPodiosView AS
SELECT a.idAtleta, a.nome, p.idPodio, p.descricao
FROM
	Atleta a
JOIN
	Podio p
ON
	a.idAtleta = p.idAtleta;
    
-- Listar todos os eventos e os seus resultados e atletas

CREATE VIEW EventosAtletasResultadosView AS
SELECT e.idEvento, e.nome AS 'Nome do Evento', a.idAtleta, a.nome AS 'Nome do Atleta', r.idResultado, r.posicao, r.detalhes
FROM
	Evento e
JOIN
	Resultado r
ON
	e.idEvento = r.idEvento
JOIN
	Atleta a
ON
	a.idAtleta = r.idAtleta;

-- Listar todos os funcionarios e os seus eventos

CREATE VIEW FuncionariosEventosView AS
SELECT f.idFuncionario, f.nome AS 'Nome do Funcionario', f.dataNascimento, f.tipo, f.idContacto, f.edicao, e.idEvento, e.nome AS 'Nome do Evento', e.dataEvento
FROM
	Funcionario f
JOIN
	Evento_has_funcionario ehf
ON
	f.idFuncionario = ehf.idFuncionario AND f.edicao = ehf.edicao
JOIN
	Evento e
ON
	ehf.idEvento = e.idEvento;

-- Listar modalidades e os seus eventos

CREATE VIEW ModalidadesEventosView AS
SELECT 
    m.idModalidade, m.nome AS 'Nome da Modalidade', e.idEvento, e.nome AS 'Nome do Evento', e.dataEvento
FROM 
    MODALIDADE m
LEFT JOIN 
    EVENTO e
ON 
    m.idModalidade = e.idModalidade;
    
-- Listar todos os testes de Doping de todos os Atletas

CREATE VIEW AtletasTestesDoping AS
SELECT 
	a.idAtleta, a.nome, t.idTesteDoping, t.dataRealizado, t.tipo, t.resultado, t.observacoes, t.idPassaporteBiologico
FROM
	Atleta a
JOIN
	PassaporteBiologico pb
ON
	pb.idAtleta = a.idAtleta
JOIN
	TesteDoping t
ON
	pb.idPassaporteBiologico = t.idPassaporteBiologico;
	