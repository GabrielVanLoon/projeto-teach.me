-- Selecionar, para cada turma existente na base de dados, a quantidade de aulas finalizadas.
-- Se uma turma ainda não tem nenhuma aula finalizada, a resposta deve vir com o resultado zero.
--    [Fácil - Junções]
-- Teste: OK

SELECT T.NOME, COUNT(A.NUMERO) AS QUANTIDADE 
  FROM turma T
  LEFT JOIN proposta P ON (P.TURMA = T.NOME)
  LEFT JOIN aula A ON (P.ID = A.PROPOSTA AND A.STATUS = 'FINALIZADA')
  GROUP BY T.NOME;

-- Selecionar as aulas(proposta e numero) que o(um) aluno 'felipe'(específico) participou, mas ainda nao avaliou
--    [Fácil - Alberto]
-- Tentar melhorar segunda parte (eficiente?/diminuir qtt de junções?)
-- Teste:

SELECT AU.PROPOSTA, AU.NUMERO
  FROM participante PA
  INNER JOIN aceita AC ON (PA.ALUNO = AC.ALUNO AND PA.TURMA = AC.TURMA)
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  WHERE PA.ALUNO = 'felipe' AND AU.STATUS = 'FINALIZADA'
EXCEPT
SELECT AU.PROPOSTA, AU.NUMERO
  FROM participante PA
  INNER JOIN aceita AC ON (PA.ALUNO = AC.ALUNO AND PA.TURMA = AC.TURMA)
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  INNER JOIN avaliacao_participante AP ON (AP.ALUNO = PA.ALUNO AND AP.TURMA = PA.TURMA AND AP.PROPOSTA = AU.PROPOSTA AND AP.NUMERO = AU.NUMERO);

--Versao 2 (menos junções)
SELECT AU.PROPOSTA, AU.NUMERO
  FROM aceita AC
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  WHERE AC.ALUNO = 'felipe' AND AU.STATUS = 'FINALIZADA'
EXCEPT
SELECT AU.PROPOSTA, AU.NUMERO
  FROM aceita AC
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  INNER JOIN avaliacao_participante AP ON (AP.ALUNO = AC.ALUNO AND AP.TURMA = AC.TURMA AND AP.PROPOSTA = AU.PROPOSTA AND AP.NUMERO = AU.NUMERO);

--Versao 3 (pegando dados de Proposta)
SELECT PR.TURMA, PR.INSTRUTOR, PR.DISCIPLINA, AU.NUMERO AS NUMERO_AULA
  FROM aceita AC
  INNER JOIN proposta PR ON (AC.PROPOSTA = PR.ID)
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  WHERE AC.ALUNO = 'felipe' AND AU.STATUS = 'FINALIZADA'
EXCEPT
SELECT PR.TURMA, PR.INSTRUTOR, PR.DISCIPLINA, AU.NUMERO AS NUMERO_AULA
  FROM aceita AC
  INNER JOIN proposta PR ON (AC.PROPOSTA = PR.ID)
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  INNER JOIN avaliacao_participante AP ON (AP.ALUNO = AC.ALUNO AND AP.TURMA = AC.TURMA AND AP.PROPOSTA = AU.PROPOSTA AND AP.NUMERO = AU.NUMERO);

-- Selecionar todos os instrutores que já deram aulas de todas disciplinas filhas de uma disciplina
--    [Fácil porém com divisão - Alberto]
-- Teste: OK
SELECT DISTINCT O.INSTRUTOR
    FROM oferecimento O
    WHERE O.INSTRUTOR not in ( 
        SELECT resto.INSTRUTOR FROM (
            -- Todas combinações possíveis dos Instrutores com TODAS disciplinas filhas de 'Computação'
            (SELECT sp.INSTRUTOR , p.DISCIPLINA 
                    FROM (select D.NOME DISCIPLINA from disciplina D WHERE D.DISCIPLINA_PAI = 'Computação') as p 
                    CROSS JOIN (select distinct O.INSTRUTOR from oferecimento O) as sp
            )
            EXCEPT -- Operação MINUS de conjuntos
            -- Combinações existentes de instrutores e disciplina 
            (SELECT O.INSTRUTOR , O.DISCIPLINA FROM oferecimento O, disciplina D WHERE (O.DISCIPLINA = D.NOME AND D.DISCIPLINA_PAI = 'Computação')) 
        )  AS resto 
    ); 

-- Selecionar todos os instrutores que um aluno já teve aula e avaliou, mas ainda não o recomendou
--    [Médio - Junções - Alberto]
-- Tentar mehorar primeira parte (muitas junções)
-- Teste:

SELECT I.NOME_USUARIO
  FROM participante PA
  INNER JOIN aceita AC ON (PA.ALUNO = AC.ALUNO AND PA.TURMA = AC.TURMA)
  INNER JOIN aula AU ON (AU.PROPOSTA = AC.PROPOSTA)
  INNER JOIN avaliacao_participante AP ON (AP.ALUNO = PA.ALUNO AND AP.TURMA = PA.TURMA AND AP.PROPOSTA = AU.PROPOSTA AND AP.NUMERO = AU.NUMERO)
  INNER JOIN instrutor I ON (AU.INSTRUTOR = I.NOME_USUARIO)
  WHERE PA.ALUNO = 'carlos'
EXCEPT
SELECT I.NOME_USUARIO
  FROM participante PA
  INNER JOIN recomenda RE ON (RE.ALUNO = PA.ALUNO)
  INNER JOIN instrutor I ON (RE.INSTRUTOR = I.NOME_USUARIO);

-- Retornar a média de mensagens trocadas entre instrutor e lider ou aluno até a primeira proposta
--    [Médio - Alberto]

-- PRIMEIRA DATA DE INTERAÇÃO COM INSTRUTOR DE CADA TURMA
SELECT P.TURMA, P.INSTRUTOR, MIN(P.DATA_CRIACAO)--COUNT(M.NUMERO) AS QTD_MENSAGENS
  FROM proposta P
  GROUP BY P.TURMA, P.INSTRUTOR;
  
-- TODAS MENSAGENS ENVIADAS ANTES DA CRACAO DE PROPOSTA
SELECT M.TURMA, M.CODIGO, M.NUMERO, C.INSTRUTOR, M.CONTEUDO
  FROM chat C
  INNER JOIN (SELECT P.TURMA, P.INSTRUTOR, MIN(P.DATA_CRIACAO)
    FROM proposta P
    GROUP BY P.TURMA, P.INSTRUTOR) P ON (P.TURMA = C.TURMA AND P.INSTRUTOR = C.INSTRUTOR)
  INNER JOIN mensagem M ON (C.TURMA = M.TURMA AND C.CODIGO = M.CODIGO)
  WHERE C.INSTRUTOR IS NOT NULL AND M.DATA_ENVIO <= P.MIN;
  
--CONTAGEM DE MENSAGENS 
SELECT P.TURMA, P.INSTRUTOR, COUNT(*)
  FROM chat C
  INNER JOIN (SELECT P.TURMA, P.INSTRUTOR, MIN(P.DATA_CRIACAO)
    FROM proposta P
    GROUP BY P.TURMA, P.INSTRUTOR) P ON (P.TURMA = C.TURMA AND P.INSTRUTOR = C.INSTRUTOR)
  INNER JOIN mensagem M ON (C.TURMA = M.TURMA AND C.CODIGO = M.CODIGO)
  WHERE C.INSTRUTOR IS NOT NULL AND M.DATA_ENVIO <= P.MIN
  GROUP BY P.TURMA, P.INSTRUTOR;
  
--MEDIA DE MENSAGENS ENVIADAS ANTES DA PRIMEIRA PROPOSTA
SELECT AVG(CONTAGEM.COUNT) AS MSG_ANTES_PROPOSTA
  FROM (SELECT P.TURMA, P.INSTRUTOR, COUNT(*)
    FROM chat C
    INNER JOIN (SELECT P.TURMA, P.INSTRUTOR, MIN(P.DATA_CRIACAO)
      FROM proposta P
      GROUP BY P.TURMA, P.INSTRUTOR) P ON (P.TURMA = C.TURMA AND P.INSTRUTOR = C.INSTRUTOR)
    INNER JOIN mensagem M ON (C.TURMA = M.TURMA AND C.CODIGO = M.CODIGO)
    WHERE C.INSTRUTOR IS NOT NULL AND M.DATA_ENVIO <= P.MIN
    GROUP BY P.TURMA, P.INSTRUTOR) CONTAGEM;