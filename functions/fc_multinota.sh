source ./config/var.sh
source ./functions/fc_newdlpd.sh
source ./config/conn.sh

cria_pasta_multinota() {

connect_server "$HOST_ADDRESS" <<EOF
  set -e

  cp -r /var/www/html/sempre/_lib/file/doc/009000inst /var/www/html/sempre/_lib/file/doc/$DLPD || exit 1
  cp -r /var/www/html/sempre/_lib/file/img/009000inst /var/www/html/sempre/_lib/file/img/$DLPD || exit 1
  chmod -Rf 777 /var/www/html/sempre/_lib/file/doc/$DLPD || exit 1
  chmod -Rf 777 /var/www/html/sempre/_lib/file/img/$DLPD || exit 1

  cd /var/www/html/sempre/_FISCAL/009000inst || exit 1
  cp -r * /var/www/html/sempre/_FISCAL/$DLPD_PRINCIPAL || exit 1
  cd /var/www/html/sempre/_FISCAL/$DLPD_PRINCIPAL || exit 1
  rename 's/9000/${DLPD_NO_ZEROS}/' CTE9000 MDFE9000 NFCE9000 NFE9000 NFSE9000 tmp9000 || exit 1
  chmod -Rf 777 /var/www/html/sempre/_FISCAL/$DLPD_PRINCIPAL || true
EOF
}

insere_nova_empresa() {

  DATA=$(obtem_dados_dlpd)
  IFS=';' read -r -a DATA_ARRAY <<<"$DATA"

  SELECT_CNAE="
    SELECT
	    id_cnae,
	    descricao
    FROM db_gol.tb_cnae 
    WHERE id_cnae = '${DATA_ARRAY[4]}'"

  RESULT_SELECT_CNAE=$(connect_server "$HOST_ADDRESS" "psql -U postgres -d db_$DLPD_PRINCIPAL -c \"$SELECT_CNAE\" -t -A")

  if [ -z "$RESULT_SELECT_CNAE" ]; then
    INSERT_CNAE="INSERT INTO db_gol.tb_cnae(descricao, id_cnae, dt_inc, dt_atu, login) VALUES ('OUTROS', '${DATA_ARRAY[4]}', NOW(), NULL, 'admin');"
    connect_server "$HOST_ADDRESS" "psql -U postgres -d db_$DLPD_PRINCIPAL -c \"$INSERT_CNAE\""
  fi

  connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -d db_$DLPD_PRINCIPAL << 'SQL'
    INSERT INTO db_gol.tb_empresa (
      id_empresa, 
      razao_social, 
      nm_fantasia, 
      cnpj, 
      insc_estadual, 
      logradouro, 
      bairro, 
      cidade, 
      uf, 
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
      "token", 
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
      tx_link_contrato_aceite, 
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
      tx_logo_pdv_web, 
      tx_repositorio_certificado, 
      login_porto_averbacao, 
      senha_porto_averbacao, 
      dt_update_data_discovery
    ) 
    VALUES 
      (
        '$DLPD', 
        '${DATA_ARRAY[0]}', 
        '${DATA_ARRAY[1]}', 
        '${DATA_ARRAY[2]}', 
        '${DATA_ARRAY[3]}', 
        '${DATA_ARRAY[8]}', 
        '${DATA_ARRAY[11]}', 
        '${DATA_ARRAY[12]}', 
        '${DATA_ARRAY[13]}', 
        '${DATA_ARRAY[7]}', 
        '${DATA_ARRAY[15]}', 
        '${DATA_ARRAY[16]}', 
        '${DATA_ARRAY[5]}', 
        '1', 
        '${DATA_ARRAY[14]}', 
        NOW(), 
        NOW(), 
        'admin', 
        '${DATA_ARRAY[9]}', 
        '${DATA_ARRAY[10]}', 
        '1', 
        '${DATA_ARRAY[4]}', 
        '2', 
        '', 
        NULL, 
        NULL, 
        '6', 
        'D', 
        '03:00:00', 
        NULL, 
        'NFCE.jpg', 
        '', 
        '', 
        NULL, 
        NULL, 
        NULL, 
        NULL, 
        '1', 
        NULL, 
        '30', 
        '', 
        '', 
        '', 
        '0', 
        '', 
        '', 
        '', 
        '', 
        '0', 
        NULL, 
        'N', 
        NULL, 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '5300108', 
        NULL, 
        'DF', 
        '', 
        '', 
        '', 
        '', 
        '', 
        NULL, 
        '', 
        '', 
        'S', 
        'NFCE.jpg', 
        NULL, 
        '1', 
        '', 
        '', 
        '0', 
        NULL, 
        NULL, 
        'N', 
        'S', 
        NULL, 
        NULL, 
        NULL, 
        NULL, 
        NULL, 
        NULL, 
        '0', 
        'N', 
        NULL, 
        '', 
        '', 
        'N', 
        '', 
        '', 
        1, 
        NULL, 
        NULL, 
        'N', 
        'N', 
        'N', 
        'N', 
        'N', 
        '', 
        'DIMEP', 
        'client_credentials', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        '', 
        'N', 
        NULL, 
        '', 
        '', 
        '', 
        '', 
        '', 
        'S', 
        NULL, 
        NULL, 
        NULL, 
        '', 
        '', 
        '', 
        NULL, 
        '', 
        NULL, 
        NULL, 
        NULL
      );
SQL
EOF
}

executa_script_multinota() {
  connect_server "$HOST_ADDRESS" <<EOF
    psql -U postgres -d db_$DLPD_PRINCIPAL << 'SQL'
    BEGIN;
INSERT INTO db_gol.tb_formapg
(SELECT id_forma, desc_forma, mensagem, obs_nota, dt_inc, dt_atu, login, 
       lo_tipo_boleto, $DLPD_NO_ZEROS, id_baixa_detalhe, id_baixa_lote, 
       lo_baixa_auto, lo_permite_troco, lo_tipo_cartao, nu_forma_cupom, 
       vr_minimo_fat, id_forma_sefaz, lo_libera_venda
  FROM db_gol.tb_formapg WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_forma NOT IN (
	SELECT id_forma FROM db_gol.tb_formapg WHERE id_empresa = $DLPD_NO_ZEROS
  ) );

INSERT INTO db_gol.tb_plano_conta (
SELECT $DLPD_NO_ZEROS, id_plano_conta, desc_plano_conta, sintetico, dt_inc, 
       dt_atu, login, lo_visualiza_balancete, lo_tipo_plano_conta, lo_lucro_operacional
   FROM db_gol.tb_plano_conta WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_plano_conta NOT IN (
	SELECT id_plano_conta FROM db_gol.tb_plano_conta WHERE id_empresa = $DLPD_NO_ZEROS
  ) ) ;

DELETE FROM db_gol.tb_msysparam where id_empresa = $DLPD_NO_ZEROS;
DELETE FROM db_cte.tb_msysparam_cte where id_empresa = $DLPD_NO_ZEROS;

INSERT INTO db_gol.tb_parametro (
SELECT $DLPD_NO_ZEROS, tx_descricao, tx_tipo_dado, tx_rotulo, tx_ajuda, 
       tx_valor, dt_inc, dt_atu, login
  FROM db_gol.tb_parametro WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND (id_empresa, tx_descricao) NOT IN (
	SELECT id_empresa, tx_descricao FROM db_gol.tb_parametro WHERE id_empresa = $DLPD_NO_ZEROS
 ));

INSERT INTO db_gol.tb_msysparam(
            id_empresa, conta_rec, conta_pg, conta_juros_rec, conta_juros_pg, 
            conta_transf, conta_desconto_pg, conta_desconto_rec, juros, multa, 
            senhapadrao, vr_boleto, boleto_laser, cadastro_multi, estoque_neg, 
            servidor_email, usuario_email, senha_email, email_contador, dt_inc, 
            dt_atu, login, id_local_stq, bloqueio_preco, dir_sistema, desc_prod_add, 
            cfop_dentro, cfop_fora, tipo_servidor, dir_db, sys_versao, transp_venda, 
            nfe_amb, nfe_forma_em, imp_cupom, id_grupo_mkt, id_centro_custo, 
            id_pessoa_lanc_transf, lo_doc_opcional, id_grupo_adm_vd, tx_impressora_pedido_matricial, 
            lo_limite_credito, id_venda_fluxo, nu_via_cupom_nao_fiscal, id_tipo_preco_custo, 
            nu_tipo_impressao_pedido_padrao, nu_copia_pedido, nu_via_pedido_padrao, 
            lo_obs_venda_boleto, id_grupo_del_fat, id_tipo_comissao, nu_dias_atraso, 
            id_tipo_tabela_preco, nu_loop_lote_nfe, conta_cc_pessoa_pg, conta_cc_pessoa_rec, 
            id_detalhe_cc_pessoa, lo_fatura_duplicata_nfe, lo_grupo_mkt_ins_pessoa, 
            dt_modo_scan, id_detalhe_desconto, id_grupo_ins_ent, id_grupo_ins_sai, 
            lo_visualizar_nfe, tx_just_modo_scan, id_grupo_visualiza_conta, 
            lo_bloqueio_stq_negativo, id_grupo_del_fin, id_grupo_visualiza_estorno, 
            lo_visualiza_volume_nfe, lo_visualiza_centro_custo_venda, tx_assunto_email, 
            tx_msg_email, tx_msg_recibo, tx_tipo_boleto, id_grupo_fecha_caixa_lote, 
            lo_calcula_peso_padrao, lo_carregamento_dt_anterior, lo_exibe_pedido_monitor, 
            id_sit_trib_padrao, lo_bloqueia_produto_descricao, lo_dia_util, 
            lo_duplica_nr_talao, tx_copia_email, nu_espera_retorno_nfe, lo_centro_custo_det_baixa, 
            tx_tipo_centro_custo, lo_cfop_item_venda, lo_imp_pedido_digitacao, 
            lo_tipo_local_estoque, lo_visualiza_dt_inc_vd, id_grupo_estorna_stq, 
            lo_venda_consumidor, vr_teto_ret_pis_cofins, id_grupo_libera_venda, 
            lo_bloq_cliente_atraso_venda, lo_codigo_personalizado, lo_imp_ecf, 
            lo_limite_desc_prod_pedido, id_grupo_delete_doc, lo_pedido_email, 
            vr_piso_irrf, lo_exibe_obs_nr_talao, lo_bc_iss_zero, lo_digita_nr_nota_faturar, 
            id_grupo_supervisor_venda, tipo_cfop, lo_manter_dt_venda_pedido_p_nfe, 
            lo_produto_st_por_uf, lo_peso_peca_suina, lo_exibe_cidade_cliente_grid_venda, 
            dt_trava_baixa, id_formapg_bonif, id_plano_conta_bonif, id_detalhe_bonif, 
            lo_exibe_dados_os, lo_exibe_msg_lei_transparencia, perc_aliquota_simples_lei_transparencia, 
            lo_exibe_msg_venda_nf, tx_config_mapa, lo_exibe_orcamento_venda, 
            lo_exibe_troca_conf, lo_add_prod_tabela_preco, id_detalhe_cc_pessoa_fornecedor, 
            lo_exibe_peso_carga, lo_incluir_serie_faturar, lo_autoriza_pgto_fin, 
            id_grupo_autoriza_pgto_fin, lo_id_pessoa_razao_emit_nfe, lo_quebra_obs_nfe, 
            id_grupo_exibe_valor_posicao_stq, id_grupo_cancela_nfe, lo_bloqueia_compra_repetida, 
            nu_versao_nfe, lo_bloqueia_stq_transitorio, lo_orcamento_influi_saldo, 
            lo_replica_dados_empresa, id_grupo_edita_prazo_venda, tx_tipo_desc_max_venda, 
            tx_tipo_faixa_comissao, lo_multiplas_comissoes_venda, lo_exibe_vr_unit_mapa_sep, 
            lo_bloqueia_forma_pgto, nu_casa_decimal_vr_unit_venda, lo_exibe_obs_interna_venda, 
            lo_tabela_preco_uf, lo_valor_imposto_pedido, lo_exibe_vr_total_nota_venda, 
            lo_utiliza_perc_icms_diferenciado, lo_boleto_exibe_nome_vendedor, 
            lo_plano_contabil_por_fornecedor, id_grupo_exibe_botao_producao, 
            lo_exibe_dados_comp_transp, lo_servico_exibe_nome_vendedor, lo_utiliza_cod_pers_pedido, 
            lo_utiliza_produto_pai, lo_exibe_reg_trib_cliente, id_grupo_exibe_vr_unit_mapa_separacao, 
            id_grupo_exibe_vr_transf_produto, lo_imp_pedido_venda, lo_det_cheque_devol, 
            lo_exibe_cod_pers_pos_stq, lo_peso_peca, lo_bloqueia_nota_atraso, 
            tx_ambiente_so, tx_unidade_rede, lo_exibe_aba_servico_venda, 
            lo_exibe_form_item_venda_aberto, lo_exibe_local_estoque_item, 
            lo_exibe_serie_monitor, lo_exibe_metros_cubicos_und_medida, lo_emite_nfce, 
            id_grupo_altera_banco_boleto, id_grupo_estorna_finaliza_ped_compra, 
            lo_atualiza_volume_cab_venda, id_grupo_add_anexo_c_l, tx_tipo_dt_saida, 
            lo_imprime_nfce_auto, lo_orcamento_financeiro, lo_checkout, tx_msg_recibo2, 
            tx_tipo_desconto_item, lo_cancela_nota_entregue, lo_descricao_automatica, 
            lo_sempre_auto, lo_exibe_msg_nota, vr_max_nota_fiscal, vr_max_nota_fiscal_dia, 
            lo_bc_iss_reduzida, tx_tipo_doc_ff, tp_nfe_cadastro_cliente_fornecedor, 
            tx_componente, lo_config_palm, lo_exibe_hora_saida, lo_verifica_estoque_faturamento, 
            lo_valida_carga_maxi, lo_verifica_produto_desativado, conta_ret_pis, 
            conta_ret_cofins, conta_ret_csll, conta_ret_irrf, conta_ret_prev, 
            conta_ret_iss, tx_msg_recibo3, lo_valida_carga_max, tx_tipo_plano_conta, 
            nu_perc_multa_rec, id_formapg_desd_rec, lo_verifica_item_venda, 
            nu_qtd_anos_rec, lo_sempre_contabilidade, vr_perc_multa, lo_exibe_valor_liquido_nota, 
            lo_cod_personalizado, lo_busca_preco_vi_ult_venda, lo_exibe_perc_cliente, 
            tx_tipo_fiscal, lo_exibe_dados_sesi, tx_msg_recibo_credito, lo_rastreabilidade, 
            id_grupo_altera_lote, lo_nova_tributacao, lo_cust_fat_dup, tx_recibo_lote, 
            lo_utliza_curso, enviado_de, tx_msg_email_aniversario)
    (
SELECT $DLPD_NO_ZEROS, conta_rec, conta_pg, conta_juros_rec, conta_juros_pg, 
            conta_transf, conta_desconto_pg, conta_desconto_rec, juros, multa, 
            senhapadrao, vr_boleto, boleto_laser, cadastro_multi, estoque_neg, 
            servidor_email, usuario_email, senha_email, email_contador, dt_inc, 
            dt_atu, login, id_local_stq, bloqueio_preco, dir_sistema, desc_prod_add, 
            cfop_dentro, cfop_fora, tipo_servidor, dir_db, sys_versao, transp_venda, 
            nfe_amb, nfe_forma_em, imp_cupom, id_grupo_mkt, id_centro_custo, 
            id_pessoa_lanc_transf, lo_doc_opcional, id_grupo_adm_vd, tx_impressora_pedido_matricial, 
            lo_limite_credito, id_venda_fluxo, nu_via_cupom_nao_fiscal, id_tipo_preco_custo, 
            nu_tipo_impressao_pedido_padrao, nu_copia_pedido, nu_via_pedido_padrao, 
            lo_obs_venda_boleto, id_grupo_del_fat, id_tipo_comissao, nu_dias_atraso, 
            id_tipo_tabela_preco, nu_loop_lote_nfe, conta_cc_pessoa_pg, conta_cc_pessoa_rec, 
            id_detalhe_cc_pessoa, lo_fatura_duplicata_nfe, lo_grupo_mkt_ins_pessoa, 
            dt_modo_scan, id_detalhe_desconto, id_grupo_ins_ent, id_grupo_ins_sai, 
            lo_visualizar_nfe, tx_just_modo_scan, id_grupo_visualiza_conta, 
            lo_bloqueio_stq_negativo, id_grupo_del_fin, id_grupo_visualiza_estorno, 
            lo_visualiza_volume_nfe, lo_visualiza_centro_custo_venda, tx_assunto_email, 
            tx_msg_email, tx_msg_recibo, tx_tipo_boleto, id_grupo_fecha_caixa_lote, 
            lo_calcula_peso_padrao, lo_carregamento_dt_anterior, lo_exibe_pedido_monitor, 
            id_sit_trib_padrao, lo_bloqueia_produto_descricao, lo_dia_util, 
            lo_duplica_nr_talao, tx_copia_email, nu_espera_retorno_nfe, lo_centro_custo_det_baixa, 
            tx_tipo_centro_custo, lo_cfop_item_venda, lo_imp_pedido_digitacao, 
            lo_tipo_local_estoque, lo_visualiza_dt_inc_vd, id_grupo_estorna_stq, 
            lo_venda_consumidor, vr_teto_ret_pis_cofins, id_grupo_libera_venda, 
            lo_bloq_cliente_atraso_venda, lo_codigo_personalizado, lo_imp_ecf, 
            lo_limite_desc_prod_pedido, id_grupo_delete_doc, lo_pedido_email, 
            vr_piso_irrf, lo_exibe_obs_nr_talao, lo_bc_iss_zero, lo_digita_nr_nota_faturar, 
            id_grupo_supervisor_venda, tipo_cfop, lo_manter_dt_venda_pedido_p_nfe, 
            lo_produto_st_por_uf, lo_peso_peca_suina, lo_exibe_cidade_cliente_grid_venda, 
            dt_trava_baixa, id_formapg_bonif, id_plano_conta_bonif, id_detalhe_bonif, 
            lo_exibe_dados_os, lo_exibe_msg_lei_transparencia, perc_aliquota_simples_lei_transparencia, 
            lo_exibe_msg_venda_nf, tx_config_mapa, lo_exibe_orcamento_venda, 
            lo_exibe_troca_conf, lo_add_prod_tabela_preco, id_detalhe_cc_pessoa_fornecedor, 
            lo_exibe_peso_carga, lo_incluir_serie_faturar, lo_autoriza_pgto_fin, 
            id_grupo_autoriza_pgto_fin, lo_id_pessoa_razao_emit_nfe, lo_quebra_obs_nfe, 
            id_grupo_exibe_valor_posicao_stq, id_grupo_cancela_nfe, lo_bloqueia_compra_repetida, 
            nu_versao_nfe, lo_bloqueia_stq_transitorio, lo_orcamento_influi_saldo, 
            lo_replica_dados_empresa, id_grupo_edita_prazo_venda, tx_tipo_desc_max_venda, 
            tx_tipo_faixa_comissao, lo_multiplas_comissoes_venda, lo_exibe_vr_unit_mapa_sep, 
            lo_bloqueia_forma_pgto, nu_casa_decimal_vr_unit_venda, lo_exibe_obs_interna_venda, 
            lo_tabela_preco_uf, lo_valor_imposto_pedido, lo_exibe_vr_total_nota_venda, 
            lo_utiliza_perc_icms_diferenciado, lo_boleto_exibe_nome_vendedor, 
            lo_plano_contabil_por_fornecedor, id_grupo_exibe_botao_producao, 
            lo_exibe_dados_comp_transp, lo_servico_exibe_nome_vendedor, lo_utiliza_cod_pers_pedido, 
            lo_utiliza_produto_pai, lo_exibe_reg_trib_cliente, id_grupo_exibe_vr_unit_mapa_separacao, 
            id_grupo_exibe_vr_transf_produto, lo_imp_pedido_venda, lo_det_cheque_devol, 
            lo_exibe_cod_pers_pos_stq, lo_peso_peca, lo_bloqueia_nota_atraso, 
            tx_ambiente_so, tx_unidade_rede, lo_exibe_aba_servico_venda, 
            lo_exibe_form_item_venda_aberto, lo_exibe_local_estoque_item, 
            lo_exibe_serie_monitor, lo_exibe_metros_cubicos_und_medida, lo_emite_nfce, 
            id_grupo_altera_banco_boleto, id_grupo_estorna_finaliza_ped_compra, 
            lo_atualiza_volume_cab_venda, id_grupo_add_anexo_c_l, tx_tipo_dt_saida, 
            lo_imprime_nfce_auto, lo_orcamento_financeiro, lo_checkout, tx_msg_recibo2, 
            tx_tipo_desconto_item, lo_cancela_nota_entregue, lo_descricao_automatica, 
            lo_sempre_auto, lo_exibe_msg_nota, vr_max_nota_fiscal, vr_max_nota_fiscal_dia, 
            lo_bc_iss_reduzida, tx_tipo_doc_ff, tp_nfe_cadastro_cliente_fornecedor, 
            tx_componente, lo_config_palm, lo_exibe_hora_saida, lo_verifica_estoque_faturamento, 
            lo_valida_carga_maxi, lo_verifica_produto_desativado, conta_ret_pis, 
            conta_ret_cofins, conta_ret_csll, conta_ret_irrf, conta_ret_prev, 
            conta_ret_iss, tx_msg_recibo3, lo_valida_carga_max, tx_tipo_plano_conta, 
            nu_perc_multa_rec, id_formapg_desd_rec, lo_verifica_item_venda, 
            nu_qtd_anos_rec, lo_sempre_contabilidade, vr_perc_multa, lo_exibe_valor_liquido_nota, 
            lo_cod_personalizado, lo_busca_preco_vi_ult_venda, lo_exibe_perc_cliente, 
            tx_tipo_fiscal, lo_exibe_dados_sesi, tx_msg_recibo_credito, lo_rastreabilidade, 
            id_grupo_altera_lote, lo_nova_tributacao, lo_cust_fat_dup, tx_recibo_lote, 
            lo_utliza_curso, enviado_de, tx_msg_email_aniversario
  FROM db_gol.tb_msysparam WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

INSERT INTO db_cte.tb_msysparam_cte (
SELECT $DLPD_NO_ZEROS, tx_versao_layout_cte, nu_formato_impressao, nu_forma_emissao, 
       nu_tipo_ambiente, nu_versao_sistema, id_pessoa_tomador_padrao, 
       id_pessoa_remetente_padrao, id_pessoa_expedidor_padrao, id_pessoa_recebedor_padrao, 
       id_pessoa_destinatario_padrao, dt_inc, dt_atu, tx_login, nu_cfop_dentro, 
       nu_cfop_fora, nu_modelo, nu_serie_cte, tx_observacao_padrao, 
       nu_rntrc, tx_apolice, tx_nome_seguradora, nu_perc_icms, tx_cst_padrao, 
       vr_perc_red_bc, tx_carrega_munic_inicio
  FROM db_cte.tb_msysparam_cte WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

INSERT INTO db_gol.tb_ncm (
SELECT id_ncm, descricao, dt_inc, dt_atu, login, nu_ex, nu_tabela, nu_aliqnac, 
       nu_aliqimp, nu_versao, descricao_ibpt, $DLPD_NO_ZEROS, tx_cod_cest
  FROM db_gol.tb_ncm WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

INSERT INTO db_gol.tb_sit_tributaria(
SELECT aliquota_credito_csosn, csosn, cst, cst_fora, descricao, dt_atu, 
      dt_inc, $DLPD_NO_ZEROS, id_sit_tributaria, login, modalidade_subs, 
      msg_info_adic, msg_info_adic_fora, per_icms, per_icms_subs, per_iss, 
      per_mva, per_red_bcicms_subs, per_red_iss, per_reducao_bcicms, 
      per_reducao_bcicms_fora, vr_credito_csosn, perc_ret_cofins, perc_ret_csll, 
      perc_ret_irrf, perc_ret_pis, perc_ret_prev, tx_cod_aliq_personalizado, 
      perc_ret_iss, cfop_dentro, cfop_fora
 FROM db_gol.tb_sit_tributaria WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL
);

INSERT INTO db_gol.tb_produto_tributo (
SELECT $DLPD_NO_ZEROS, id_produto, id_sit_tributaria, per_cofins, per_ipi, 
      per_mva, per_pis, sit_trib_ipi, tipo_ipi, vr_preco_pauta, cst_cofins, 
      cst_pis
 FROM db_gol.tb_produto_tributo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL
);

INSERT INTO db_gol.tb_cfop(
SELECT		id_cfop
		, descricao
	--	, tipo
		, dt_inc
		, dt_atu
		, login
		, isento
		, lo_atu_fin
		, lo_atu_stq
		, $DLPD_NO_ZEROS
		, tx_tipo_movimentacao
		, tx_tipo_sefaz
		, lo_sincroniza_palm
 FROM db_gol.tb_cfop WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL
);

INSERT INTO db_gol.tb_icms_uf (
SELECT $DLPD_NO_ZEROS, id_uf, perc_icms, dt_inc, dt_atu, login
FROM db_gol.tb_icms_uf WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL
);

INSERT INTO db_gol.tb_atalho (
SELECT id_nome_apl, $DLPD_NO_ZEROS, tx_descricao, tx_icone, tx_ativo, dt_inc, 
       dt_atu, login
  FROM db_gol.tb_atalho WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

INSERT INTO db_gol.tb_atalho_grupo (
SELECT id_atalho_grupo, $DLPD_NO_ZEROS, tx_descricao, dt_inc, dt_atu, login, 
       tx_ativo
  FROM db_gol.tb_atalho_grupo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

COMMIT;

SQL
EOF
}

configura_parametros_multinota() {

  UPDATE_PARAMETRO="
  UPDATE db_gol.tb_msysparam SET
	  cadastro_multi='S',
	  nfe_amb='1';
  
  UPDATE db_gol.tb_parametro SET 
    tx_valor='S'
  WHERE tx_descricao='utiliza_multinota'"

  connect_server "$HOST_ADDRESS" <<EOF
  psql -U postgres -d db_$DLPD_PRINCIPAL -c "$UPDATE_PARAMETRO"
EOF

}

export -f insere_nova_empresa
export -f executa_script_multinota
export -f configura_parametros_multinota