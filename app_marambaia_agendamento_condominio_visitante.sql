﻿CREATE OR REPLACE FUNCTION public.visitantecondominio(
    IN rg_visit character varying,
    IN data_venc date,
    IN nome_visit character varying,
    IN id_morad integer,
    IN placa_visit character varying,
    IN boolean_foto integer)
  RETURNS TABLE(id_visitante integer, mensagens character varying) AS
$BODY$

Declare

	return_id bigint;
	
	    
begin

 CREATE TEMP TABLE IF NOT EXISTS retorno(id_visitante_return int, mensagem varchar(80));


/* Visitante existe?*/
    if exists (select cv.rg
                  from   condominiovisitante as cv
                  where  cv.rg = rg_visit)

    /* Se sim */           
    then
    /* Consulta se tem moradia atrelada*/
	if exists(select cv.rg
                  from   condominiovisitante as cv
                  INNER JOIN joincondominiovisitantemoradia as jvm on jvm.id_condominiovisitante = cv.id 
		  INNER JOIN moradia as mor on mor.id = jvm.id_moradia and jvm.id_moradia = mor.id
                  where  cv.rg = rg_visit and jvm.id_moradia = id_morad )

                  
	/* Se sim */
               then 
               
               /* Faz o update da data de vencimento */
			UPDATE joincondominiovisitantemoradia SET	
			data_vencimento =data_venc
			WHERE	
			id_condominiovisitante = (select id from condominiovisitante where rg = rg_visit) and id_moradia = id_morad;

			
		/* Verifica se tem veículo */
			if not exists( select placa from veiculo where placa = placa_visit and id_condominiovisitante = (select id from condominiovisitante where rg = rg_visit)) 
		 /* Se não tem veiculo */
                        then
		/* insere o veículo */
			INSERT INTO veiculo (id,data_cadastro,id_visitante,marca,modelo,nome_responsavel,placa,situacao_veiculo,utiliza_vaga_fixa,id_colaborador,id_terceiro,cor,id_prestadorservico,observacao,renavan,tipoveiculo,id_condominiovisitante,id_moradia,id_municipio,id_morador) 
			VALUES (nextval('public.veiculo_seq'),(select CURRENT_DATE),null,'SEM MARCA','SEM MODELO',null,placa_visit,'A',null,null,null,'SEM COR',null,null,null,'2',(select id from condominiovisitante where rg = rg_visit),null,null,null);

						
			end if;

			if (boolean_foto=0)
			then
		
			select id into return_id from condominiovisitante where rg = rg_visit;
			
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso sem Foto');

			return query select * from retorno;
			
			drop table retorno;
			 		
			
			
			else
			 update "condominiovisitante" set "foto_visitante" = (select lo_import('//srv-dominio/Fotos/'||rg_visit||'.jpg')) where rg= rg_visit;

			select id into return_id from condominiovisitante where rg = rg_visit;
			
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso com Foto');

			return query select * from retorno;

			drop table retorno;

			end if;            

               
		/* Se não existe moradia atrelada */
		else 
		  /* Faz o insert do da pessoa no joincondominiovisitantemoradia com a foto */
			INSERT INTO joincondominiovisitantemoradia (id,data_vencimento,id_condominiovisitante,id_moradia,id_veiculo) 
			values (nextval('public.joincondominiovisitantemoradia_seq'),data_venc,(select id from condominiovisitante where rg = rg_visit),id_morad,null);	

		/* Verifica se tem veículo */
			if not exists( select placa from veiculo where placa = placa_visit and id_condominiovisitante = (select id from condominiovisitante where rg = rg_visit)) 
		 /* Se não tem veiculo */
                        then
		/* insere o veículo */
			INSERT INTO veiculo (id,data_cadastro,id_visitante,marca,modelo,nome_responsavel,placa,situacao_veiculo,utiliza_vaga_fixa,id_colaborador,id_terceiro,cor,id_prestadorservico,observacao,renavan,tipoveiculo,id_condominiovisitante,id_moradia,id_municipio,id_morador) 
			VALUES (nextval('public.veiculo_seq'),(select CURRENT_DATE),null,'SEM MARCA','SEM MODELO',null,placa_visit,'A',null,null,null,'SEM COR',null,null,null,'2',(select id from condominiovisitante where rg = rg_visit),null,null,null);
			
			end if;

			if (boolean_foto =0)
			then
		
			select id into return_id from condominiovisitante where rg = rg_visit;
			
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso sem Foto');			 
		
			return query select * from retorno ;	

			drop table retorno;

			else

			update "condominiovisitante" set "foto_visitante" = (select lo_import('//srv-dominio/Fotos/'||rg_visit||'.jpg')) where rg= rg_visit;
			
			select id into return_id from condominiovisitante where rg = rg_visit;
			
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso com Foto');			 
		
			return query select * from retorno ;	

			drop table retorno;
			
			end if;
	end if;	              
			
		
/* Se não */
    else 
	/* Faz o insert da pessoa na tabela condominiovisitante e na tabela joincondominiovisitantemoradia e foto e veiculo */
	INSERT INTO condominiovisitante (id,empresa,foto_documento,foto_documento_alternativo,foto_visitante,nome,observacao,telefone,nivelprecisao,tipoverificabiometria,utilizabiometria,cnh,cpf,passaporte,reservista,rg,titeleitor,cnhvalidade,dataexpedicaorg,foto_cnh_frente,foto_cnh_verso,foto_passaporte_frente,foto_passaporte_verso,foto_reservista_frente,foto_reservista_verso,foto_rg_frente,foto_rg_verso,nome_foto_cnh_frente,nome_foto_cnh_verso,nome_foto_passaporte_frente,nome_foto_passaporte_verso,nome_foto_reservista_frente,nome_foto_reservista_verso,nome_foto_rg_frente,nome_foto_rg_verso,orgaoexpedidorrg,revista,telefone_fixo)
Values (nextval('public.condominiovisitante_seq'),null,null,null,null,nome_visit,'','','1','',null,'','','','',rg_visit,'',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'',0,'');

	INSERT INTO joincondominiovisitantemoradia (id,data_vencimento,id_condominiovisitante,id_moradia,id_veiculo) 
			values (nextval('public.joincondominiovisitantemoradia_seq'),data_venc,(select id from condominiovisitante where rg = rg_visit),id_morad,null);	

		INSERT INTO veiculo (id,data_cadastro,id_visitante,marca,modelo,nome_responsavel,placa,situacao_veiculo,utiliza_vaga_fixa,id_colaborador,id_terceiro,cor,id_prestadorservico,observacao,renavan,tipoveiculo,id_condominiovisitante,id_moradia,id_municipio,id_morador) 
		VALUES (nextval('public.veiculo_seq'),(select CURRENT_DATE),null,'SEM MARCA','SEM MODELO',null,placa_visit,'A',null,null,null,'SEM COR',null,null,null,'2',(select id from condominiovisitante where rg = rg_visit),null,null,null);
	
		if (boolean_foto =0)
			
			then

			select id into return_id from condominiovisitante where rg = rg_visit;
			
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso sem Foto');
		
			return query select * from retorno;
			
			drop table retorno;

			else

			update "condominiovisitante" set "foto_visitante" = (select lo_import('//srv-dominio/Fotos/'||rg_visit||'.jpg')) where rg= rg_visit;
			
			select id into return_id from condominiovisitante where rg = rg_visit;
						
			insert into  retorno (id_visitante_return, mensagem) values (return_id , 'Sucesso com Foto');
		
			return query select * from retorno;
			
			drop table retorno;
			
			end if;
	
end if;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.visitantecondominio(character varying, date, character varying, integer, character varying, integer)
  OWNER TO postgres;