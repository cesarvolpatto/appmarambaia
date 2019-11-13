# appmarambaia
Agendamento visitante condominio

Segue parametros para executar a procedure:
-- select visitantecondominio('RGTESTE123','2019-12-06','NOME TESTE 123',14,'CAT0015',1) --
'RGTESTE123' -> RG do visitante para o condominio;
'2019-12-06' -> Data do vencimento da moradia;
'NOME TESTE 123' -> Nome do visitante condominio;
14 - > ID da moradia que o visitante irá visitar;
'CAT0015' -> Placa do carro do visitante;
1 ou 0 -> Onde 1 = foto na pasta, 0 = sem foto na pasta
Lembrando que o nome do arquivo da foto será o mesmo nome do RG.

Segue as mensagens de retorno após a execução da procedure:

Update Data Moradia sem Foto!
Update Data Moradia com Foto!
Insert em Nova Moradia sem Foto na Pasta!
Insert em Nova Moradia com Foto na Pasta!
Insert Novo Visitante Condominio Sem foto!
Insert Novo Visitante Condominio com Foto!
