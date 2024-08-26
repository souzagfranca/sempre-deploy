source ./config/var.sh
source ./config/conn.sh

altera_arquivo_inc_empresa() {

connect_server "$HOST_ADDRESS" <<EOF
    awk '
    /switch\(/ {in_switch=1}
    in_switch && /{/ {
        print
        print "            case '\''$LINK'\'': return $DLPD_NO_ZEROS;"
        print ""
        in_switch=0
        next
    }
    {print}
    ' /var/www/html/sempre/includes/ws/inc_empresa.php > /var/www/html/sempre/includes/ws/inc_empresa_temp.php
    mv /var/www/html/sempre/includes/ws/inc_empresa_temp.php /var/www/html/sempre/includes/ws/inc_empresa.php
    chmod -Rf 777 /var/www/html/sempre/includes/ws/inc_empresa.php
EOF

}

rollback() {

connect_server "$HOST_ADDRESS" <<EOF
    rm -r /var/www/html/sempre/_lib/file/doc/$DLPD
    rm -r /var/www/html/sempre/_lib/file/img/$DLPD
    rm -r /var/www/html/sempre/_FISCAL/$DLPD
EOF

}

rollback_db() {

connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -c "DROP DATABASE IF EXISTS db_$DLPD;"
    rm -f /tmp/${PROD_SELECTED}_backup.dump
EOF

}

cria_pastas_para_novo_dlpd() {

connect_server "$HOST_ADDRESS" <<EOF
    cp -r /var/www/html/sempre/_lib/file/doc/009000inst /var/www/html/sempre/_lib/file/doc/$DLPD
    cp -r /var/www/html/sempre/_lib/file/img/009000inst /var/www/html/sempre/_lib/file/img/$DLPD
    chmod -Rf 777 /var/www/html/sempre/_lib/file/doc/$DLPD
    chmod -Rf 777 /var/www/html/sempre/_lib/file/img/$DLPD

    cp -r /var/www/html/sempre/_FISCAL/009000inst /var/www/html/sempre/_FISCAL/$DLPD
    cd /var/www/html/sempre/_FISCAL/$DLPD
    rename 's/9000/${DLPD_NO_ZEROS}/' CTE9000 MDFE9000 NFCE9000 NFE9000 NFSE9000 tmp9000
    chmod -Rf 777 /var/www/html/sempre/_FISCAL/$DLPD
EOF

}

remove_backup_stapp21() {

connect_server "172.16.1.19" <<EOF
    rm -r /var/www/html/backups/${PROD_SELECTED}_backup.dump
EOF

}

cria_novo_banco_de_dados() {

connect_server "172.16.1.19" <<EOF
    pg_dump -U postgres -Fc $PROD_SELECTED -f /tmp/${PROD_SELECTED}_backup.dump
    mv /tmp/${PROD_SELECTED}_backup.dump /var/www/html/backups/
EOF
connect_server "$HOST_ADDRESS" <<EOF
    wget http://172.16.1.19/backups/${PROD_SELECTED}_backup.dump -O /tmp/${PROD_SELECTED}_backup.dump
    psql -U postgres -c "CREATE DATABASE db_$DLPD WITH OWNER postgres;"
    pg_restore -U postgres -d db_$DLPD /tmp/${PROD_SELECTED}_backup.dump
    rm -f /tmp/${PROD_SELECTED}_backup.dump
EOF

    remove_backup_stapp21

}

executa_altera_empresa() {

connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -d db_$DLPD << 'SQL'
    DO
    \$\$
    DECLARE
    c1 record;
    v_qtd integer := 0;
    v_id_empresa_old integer := 9000;
    v_id_empresa_new integer := $DLPD_NO_ZEROS;
    BEGIN
    ALTER TABLE db_gol.tb_empresa DISABLE TRIGGER ALL;
    INSERT INTO db_gol.tb_empresa 
    SELECT
        v_id_empresa_new,
        razao_social,
        nm_fantasia,
        cnpj,
        insc_estadual,
        logradouro,
        bairro,
        cidade, uf,
        cep,
        email,
        telefone,
        responsavel,
        serie,
        ibge_cod_mun,
        dt_inc,
        dt_atu,
        login,
        nr_endereco,
        complemento_endereco,
        regime_tributario,
        cnae,
        id_tipo_sistema,
        tx_logo,
        tx_logo_pedido,
        tx_logo_contrato,
        nu_regime_esp_trib,
        lo_fuso_horario,
        tx_fuso_horario,
        tx_logo_palm,
        tx_logo_pedido_cupom,
        nm_certificado,
        senha_certificado,
        tx_logo_nfe,
        tx_logo_menu,
        id_token,
        token,
        lo_aviso_venc_certificado,
        dt_venc_certificado,
        qtd_dias_aviso_certificado,
        cod_atividade,
        tipo_recolhimento,
        operacao,
        tributacao,
        nu_incricao_municipal,
        tx_chave_acesso,
        tx_chave_parceiro,
        tx_tp_endereco,
        nat_operacao,
        tx_url_integracao,
        lo_principal,
        tx_assinatura,
        razao_social_cont,
        nome_fantasia_cont,
        cnpj_cont,
        inscricao_estadual_cont,
        cpf_contador_cont,
        nome_contador_cont,
        logradouro_cont,
        nr_endereco_cont,
        complemento_cont,
        bairro_cont,
        codigo_municipio_ibge_cont,
        estado_cont,
        uf_cont,
        cep_cont,
        telefone1_cont,
        telefone2_cont,
        crc_cont,
        email_cont,
        tx_chave_parceiro_homolog,
        cidade_cont,
        tx_chave_acesso_homolog,
        lo_ativo,
        tx_logo_termica,
        id_integracao,
        tx_seguimento,
        tx_usuario_portal_contador,
        tx_senha_portal_contador,
        nu_padrao_municipal,
        tx_logo_app,
        tx_guid,
        lo_sincronizacao_mde,
        lo_cadastro_certificado_cildix,
        tx_logo_pjbank,
        tx_logo_pjbank_aux,
        dt_recibo,
        login_recibo,
        tx_desc_recibo,
        tx_anexo_recibo,
        nu_cod_inc_trib,
        lo_contrato_aceite,
        tx_LINK_contrato_aceite,
        nu_codigo_receita_cofins,
        nu_codigo_receita_pis,
        lo_utiliza_sat,
        tx_assinatura_sat,
        tx_senha_sat,
        tx_ambiente_sat,
        tx_anexo_credenciamento_sat,
        dt_ultima_sinc_dashboard,
        utiliza_nfe,
        utiliza_cte,
        utiliza_mdfe,
        utiliza_nfse,
        utiliza_nfce,
        credentials_calendar,
        tx_modelo_equipamento_sat,
        dominio_grant_type,
        dominio_client_id,
        dominio_client_secret,
        dominio_audience,
        dominio_x_integration_key,
        dominio_integrationkey,
        id_cnae,
        tx_responsavel_tecnico,
        tx_aceite,
        dt_hora_aceite_contrato,
        tx_contrato,
        tx_cpf_aceite_contrato,
        tx_nome_aceite_contrato,
        cpf_responsavel,
        telefone_responsavel,
        lo_primeiro_boleto,
        tx_logo_nfs_e_df,
        sourceid_dda,
        externalid_dda,
        tx_ar_certificado,
        tx_ac_certificado,
        tx_email_certificado,
        tx_logo_pdv_web
    FROM db_gol.tb_empresa
    WHERE id_empresa = v_id_empresa_old;
    ALTER TABLE db_gol.tb_empresa ENABLE TRIGGER ALL;
    DELETE FROM db_os.tb_arquivo;
    DELETE FROM db_os.tb_agenda;
    DELETE FROM db_gol.tb_notfat_refnfe;
    DELETE FROM db_gol.tb_venda_refnfe;
    DELETE FROM db_gol.tb_concil_ofx;
    DELETE FROM db_gol.tb_compra_vinculo;
    DELETE FROM db_gol.tb_comanda;
    DELETE FROM db_gol.tb_calendario;
    DELETE FROM db_gol.tb_caixa_lote;
    DELETE FROM db_gol.tb_bkp_xml_venda;
    DELETE FROM db_gol.tb_anexo_email; 
    DELETE FROM db_gol.tl_venda;
    DELETE FROM db_gol.tl_venda_item;
    DELETE FROM db_gol.tb_venda_troca_mercadoria_item;
    DELETE FROM db_gol.tb_venda_item_corte; 
    DELETE FROM db_gol.tb_venda_infadic;
    DELETE FROM db_gol.tb_usuario_log;
    DELETE FROM db_gol.tb_stq_mov_custo;
    DELETE FROM db_gol.tb_produto_variacao_item;
    DELETE FROM db_gol.tb_produto_variacao;
    DELETE FROM db_gol.tb_rec_pag_anexo;
    DELETE FROM db_gol.tb_prime_email;
    DELETE FROM db_gol.tb_prazo_viculado;
    DELETE FROM db_gol.tb_log_geral;
    DELETE FROM db_gol.tb_log_acesso_aplicacoes;
    DELETE FROM db_gol.tb_envio_email_sendgrid_evento;
    DELETE FROM db_gol.tb_envio_email_sendgrid;
    DELETE FROM db_gol.tb_envio_email_sendgrid_anexo;
    UPDATE db_gol.tb_msysparam_tributacao
    SET id_empresa_emitente = v_id_empresa_new
    WHERE id_empresa_emitente = v_id_empresa_old;
    SET session_replication_role = 'replica';
    FOR c1 IN 
    SELECT 
    table_schema, table_name
    FROM information_schema.tables t
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    AND table_type = 'BASE TABLE'
    AND EXISTS (
        SELECT 
            1
        FROM information_schema.columns c
        WHERE c.table_schema = t.table_schema
        AND c.table_name = t.table_name
        AND c.column_name = 'id_empresa'
    ) AND EXISTS (
        SELECT 
            1
        FROM pg_stat_user_tables
        WHERE schemaname = t.table_schema
        AND relname = t.table_name
        AND n_live_tup > 0
    )
    ORDER BY table_schema, table_name
    LOOP
        IF(c1.table_name NOT IN('tb_empresa')) THEN
            EXECUTE 'UPDATE '||c1.table_schema||'.'||c1.table_name||' SET id_empresa = '||v_id_empresa_new||' WHERE id_empresa = '||v_id_empresa_old;
        END IF;
    END LOOP;
    SET session_replication_role = 'origin';
    DELETE FROM db_gol.tb_empresa WHERE id_empresa = v_id_empresa_old;
    END;
    \$\$;
SQL
EOF

}

insere_contrato() {

connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -d db_contrato << 'SQL'
    INSERT INTO db_contratos.tb_contratos(
        id_empresa, tx_nome_bd, tx_url, id_cobranca, 
        lo_regua_cobranca, lo_exportar_nota_contabilidade, 
        lo_integracao_automatica, lo_dda, 
        lo_emissao_automatica_venda, lo_utiliza_ifood, 
        lo_resumo_semanal_receitas, lo_resumo_semanal_despesas
    ) 
    VALUES 
    (
        $DLPD_NO_ZEROS, 'conn_$DLPD', '$LINK', 
        null, 'N', 'N', 'N', 'N', 'N', 'N', 'N','N' 
    );
SQL
EOF

}

obtem_dados_dlpd(){

    SELECT_EMPRESA_INTRANET="
    SELECT 
        TRIM(REGEXP_REPLACE(a.tx_razao_social, '[;(),\[\]{}]', '', 'g')) AS tx_razao_social,
        TRIM(REGEXP_REPLACE(a.tx_nome_fantasia, '[;(),\[\]{}]', '', 'g')) AS tx_nome_fantasia,
        TRIM(REGEXP_REPLACE(a.nu_cnpj, '[;(),\[\]{}]', '', 'g')) AS nu_cnpj,
        TRIM(REGEXP_REPLACE(a.nu_inscricao_estadual, '[;(),\[\]{}]', '', 'g')) AS nu_inscricao_estadual,
        TRIM(REGEXP_REPLACE(a.nu_cnae, '[;(),\[\]{}]', '', 'g')) AS nu_cnae,
        TRIM(REGEXP_REPLACE(a.tx_nome_empresario, '[;(),\[\]{}]', '', 'g')) AS tx_nome_empresario,
        TRIM(REGEXP_REPLACE(a.nu_cpf, '[;(),\[\]{}]', '', 'g')) AS nu_cpf,
        TRIM(REGEXP_REPLACE(a.nu_cep, '[;(),\[\]{}]', '', 'g')) AS nu_cep,
        TRIM(REGEXP_REPLACE(a.tx_endereco_empresa, '[;(),\[\]{}]', '', 'g')) AS tx_endereco_empresa,
        TRIM(REGEXP_REPLACE(a.nu_endereco_empresa_numero, '[;(),\[\]{}]', '', 'g')) AS nu_endereco_empresa_numero,
        TRIM(REGEXP_REPLACE(a.tx_endereco_complemento_empresa, '[;(),\[\]{}]', '', 'g')) AS tx_endereco_complemento_empresa,
        SUBSTRING(TRIM(REGEXP_REPLACE(a.tx_bairro_empresa, '[;(),\[\]{}]', '', 'g')) FROM 1 FOR 30 ) AS tx_bairro_empresa,
        TRIM(REGEXP_REPLACE(b.nome_munic, '[;(),\[\]{}]', '', 'g')) AS nome_munic,
        TRIM(REGEXP_REPLACE(b.sigla_uf, '[;(),\[\]{}]', '', 'g')) AS sigla_uf,
        TRIM(REGEXP_REPLACE(b.ibge_cod_mun, '[;(),\[\]{}]', '', 'g')) AS ibge_cod_mun,
        TRIM(REGEXP_REPLACE(a.tx_email_empresa, '[;(),\[\]{}]', '', 'g')) AS tx_email_empresa,
        TRIM(REGEXP_REPLACE(a.nu_telefone_empresa, '[^0-9]', '', 'g')) AS nu_telefone_empresa
    FROM db_ar.tb_pessoa a
    JOIN db_gol.tb_ibge_municipio b
    ON TRIM(a.tx_cidade_empresa) = TRIM(b.nome_munic)
    WHERE id_pessoa = $DLPD_NO_ZEROS"

    RESULT=$(psql -U postgres -d $DB_INTRANET -t -A -F";" -c "$SELECT_EMPRESA_INTRANET")

    if [ -z "$RESULT" ]; then
        return 1
        exit 1
    fi

    echo "$RESULT"

}

atualiza_dados_na_tb_empresa() {

    DATA=$(obtem_dados_dlpd)
    IFS=';' read -r -a DATA_ARRAY <<<"$DATA"

    SELECT_CNAE="
    SELECT
	    id_cnae,
	    descricao
    FROM db_gol.tb_cnae 
    WHERE id_cnae = '${DATA_ARRAY[4]}'"

    RESULT_SELECT_CNAE=$(connect_server "$HOST_ADDRESS" "psql -U postgres -d db_$DLPD -c \"$SELECT_CNAE\" -t -A")

    if [ -z "$RESULT_SELECT_CNAE" ]; then
        INSERT_CNAE="INSERT INTO db_gol.tb_cnae(descricao, id_cnae, dt_inc, dt_atu, login) VALUES ('OUTROS', '${DATA_ARRAY[4]}', NOW(), NULL, 'admin');"
        connect_server "$HOST_ADDRESS" "psql -U postgres -d db_$DLPD -c \"$INSERT_CNAE\""
    fi

    UPDATE_QUERY="
    UPDATE db_gol.tb_empresa SET
	    razao_social='${DATA_ARRAY[0]}',
	    nm_fantasia='${DATA_ARRAY[1]}',
	    cnpj='${DATA_ARRAY[2]}',
	    insc_estadual='${DATA_ARRAY[3]}',
        cnae='${DATA_ARRAY[4]}',
        responsavel='${DATA_ARRAY[5]}',
        cpf_responsavel='${DATA_ARRAY[6]}',
        cep='${DATA_ARRAY[7]}',
        logradouro='${DATA_ARRAY[8]}',
        nr_endereco='${DATA_ARRAY[9]}',
        complemento_endereco='${DATA_ARRAY[10]}',
        bairro='${DATA_ARRAY[11]}',
        cidade='${DATA_ARRAY[12]}',
        uf='${DATA_ARRAY[13]}',
        ibge_cod_mun='${DATA_ARRAY[14]}',
        email='${DATA_ARRAY[15]}',
        telefone='${DATA_ARRAY[16]}'
    WHERE id_empresa = $DLPD_NO_ZEROS"

connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -d db_$DLPD -c "$UPDATE_QUERY"
EOF

}

atualiza_licenca_axm() {

    URL="https://$LINK.sempretecnologia.com.br"
    DB="conektic_geral"
    SERVER_INT="${server: -2}"

    QUERY_UPDATE_URL="UPDATE db_sempre.tb_cliente_acesso SET 
    palm_ws_url='$URL'
    WHERE id_cliente = $DLPD_NO_ZEROS"

    QUERY_UPDATE_DB_INTRANET="UPDATE db_ar.tb_pessoa SET
    id_servidor = '$SERVER_INT'
    WHERE id_pessoa = $DLPD_NO_ZEROS"

    SQL="UPDATE db_sempre.tb_cliente SET
	licenca_nfe=1,
	licenca_palm=1,
	licenca_cte=1,
	licenca_nfce=1,
	licenca_mdfe=1
    WHERE id_cliente = $DLPD_NO_ZEROS;
    
    $QUERY_UPDATE_URL
    "
    
    psql -U postgres -d $DB -c "$SQL"
    psql -U postgres -d $DB_INTRANET -c "$QUERY_UPDATE_DB_INTRANET"

}

export -f altera_arquivo_inc_empresa
export -f cria_pastas_para_novo_dlpd
export -f cria_novo_banco_de_dados
export -f executa_altera_empresa
export -f insere_contrato
export -f atualiza_dados_na_tb_empresa
export -f atualiza_licenca_axm