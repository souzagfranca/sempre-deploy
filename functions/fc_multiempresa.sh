source ./config/var.sh

insere_contrato_multiempresa() {
    ssh sempre@$HOST_ADDRESS <<EOF
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
        $DLPD_NO_ZEROS, 'conn_$DLPD_PRINCIPAL', '$LINK', 
        null, 'N', 'N', 'N', 'N', 'N', 'N', 'N','N' 
    );
SQL
EOF
}

executa_script_multiempresa() {
    ssh sempre@$HOST_ADDRESS <<EOF
    psql -U postgres -d db_$DLPD_PRINCIPAL << 'SQL'
    DELETE FROM db_gol.tb_msysparam WHERE id_empresa = $DLPD_NO_ZEROS; 
    DELETE FROM db_gol.tb_parametro WHERE id_empresa = $DLPD_NO_ZEROS;

    INSERT INTO db_gol.tb_parametro (
    SELECT $DLPD_NO_ZEROS, tx_descricao, tx_tipo_dado, tx_rotulo, tx_ajuda, 
        tx_valor, dt_inc, dt_atu, login
    FROM db_gol.tb_parametro WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND tx_descricao NOT IN (SELECT tx_descricao FROM db_gol.tb_parametro WHERE id_empresa = $DLPD_NO_ZEROS)
    );

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
        lo_produto_st_por_uf, lo_exibe_cidade_cliente_grid_venda, dt_trava_baixa, 
        lo_peso_peca_suina, id_formapg_bonif, id_plano_conta_bonif, id_detalhe_bonif, 
        lo_exibe_dados_os, lo_exibe_msg_lei_transparencia, perc_aliquota_simples_lei_transparencia, 
        lo_exibe_msg_venda_nf, lo_exibe_orcamento_venda, lo_exibe_troca_conf, 
        lo_add_prod_tabela_preco, id_detalhe_cc_pessoa_fornecedor, tx_config_mapa, 
        lo_incluir_serie_faturar, lo_autoriza_pgto_fin, id_grupo_autoriza_pgto_fin, 
        lo_id_pessoa_razao_emit_nfe, lo_quebra_obs_nfe, lo_exibe_peso_carga, 
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
        (SELECT $DLPD_NO_ZEROS, conta_rec, conta_pg, conta_juros_rec, conta_juros_pg, 
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
        lo_produto_st_por_uf, lo_exibe_cidade_cliente_grid_venda, dt_trava_baixa, 
        lo_peso_peca_suina, id_formapg_bonif, id_plano_conta_bonif, id_detalhe_bonif, 
        lo_exibe_dados_os, lo_exibe_msg_lei_transparencia, perc_aliquota_simples_lei_transparencia, 
        lo_exibe_msg_venda_nf, lo_exibe_orcamento_venda, lo_exibe_troca_conf, 
        lo_add_prod_tabela_preco, id_detalhe_cc_pessoa_fornecedor, tx_config_mapa, 
        lo_incluir_serie_faturar, lo_autoriza_pgto_fin, id_grupo_autoriza_pgto_fin, 
        lo_id_pessoa_razao_emit_nfe, lo_quebra_obs_nfe, lo_exibe_peso_carga, 
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

    INSERT INTO db_gol.tb_grupo_usuario(
                codigo_grupo, descricao, id_empresa, id_centro_custo, id_local_estoque)
    (SELECT codigo_grupo, descricao, $DLPD_NO_ZEROS, id_centro_custo, id_local_estoque
    FROM db_gol.tb_grupo_usuario WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND codigo_grupo not in (SELECT codigo_grupo FROM db_gol.tb_grupo_usuario WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_produto_marca(
                id_empresa, id_marca, tx_descricao, lo_ativo, dt_inc, dt_atu, 
        login)
    (SELECT $DLPD_NO_ZEROS, id_marca, tx_descricao, lo_ativo, dt_inc, dt_atu, 
        login
    FROM db_gol.tb_produto_marca WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_marca in (1)
    );

    INSERT INTO db_gol.tb_prod_grupo(
                id_grupo, desc_grupo, dt_inc, dt_atu, login, id_empresa, lo_grupo_venda)
    (SELECT id_grupo, desc_grupo, dt_inc, dt_atu, login, $DLPD_NO_ZEROS, lo_grupo_venda
    FROM db_gol.tb_prod_grupo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_grupo  in (1)
    );

    INSERT INTO db_gol.tb_ncm
    (SELECT id_ncm, descricao, dt_inc, dt_atu, login, nu_ex, nu_tabela, nu_aliqnac, 
        nu_aliqimp, nu_versao, descricao_ibpt, $DLPD_NO_ZEROS
    FROM db_gol.tb_ncm WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_ncm not in (SELECT id_ncm FROM db_gol.tb_ncm WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_formapg(
                id_forma, desc_forma, mensagem, obs_nota, dt_inc, dt_atu, login, 
                lo_tipo_boleto, id_empresa, id_baixa_detalhe, id_baixa_lote, 
                lo_baixa_auto, lo_tipo_cartao, lo_permite_troco, nu_forma_cupom, 
                vr_minimo_fat, id_forma_sefaz, lo_libera_venda)
        (SELECT id_forma, desc_forma, mensagem, obs_nota, dt_inc, dt_atu, login, 
        lo_tipo_boleto, $DLPD_NO_ZEROS, id_baixa_detalhe, id_baixa_lote, 
        lo_baixa_auto, lo_tipo_cartao, lo_permite_troco, nu_forma_cupom, 
        vr_minimo_fat, id_forma_sefaz, lo_libera_venda
    FROM db_gol.tb_formapg WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL  AND id_forma not in (SELECT id_forma FROM db_gol.tb_formapg WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_prazo(
                id_empresa, id_prazo, id_tipo_prazo, tx_descricao, nu_dia, nu_prazo_1, 
                nu_perc_prazo1, nu_prazo_2, nu_perc_prazo2, nu_prazo_3, nu_perc_prazo3, 
                nu_prazo_4, nu_perc_prazo4, nu_prazo_5, nu_perc_prazo5, nu_prazo_6, 
                nu_perc_prazo6, nu_prazo_7, nu_perc_prazo7, nu_prazo_8, nu_perc_prazo8, 
                nu_prazo_9, nu_perc_prazo9, nu_prazo_10, nu_perc_prazo10, nu_prazo_11, 
                nu_perc_prazo11, nu_prazo_12, nu_perc_prazo12, dt_inc, dt_atu, 
                tx_login)
        (SELECT $DLPD_NO_ZEROS, id_prazo, id_tipo_prazo, tx_descricao, nu_dia, nu_prazo_1, 
        nu_perc_prazo1, nu_prazo_2, nu_perc_prazo2, nu_prazo_3, nu_perc_prazo3, 
        nu_prazo_4, nu_perc_prazo4, nu_prazo_5, nu_perc_prazo5, nu_prazo_6, 
        nu_perc_prazo6, nu_prazo_7, nu_perc_prazo7, nu_prazo_8, nu_perc_prazo8, 
        nu_prazo_9, nu_perc_prazo9, nu_prazo_10, nu_perc_prazo10, nu_prazo_11, 
        nu_perc_prazo11, nu_prazo_12, nu_perc_prazo12, dt_inc, dt_atu, 
        tx_login
    FROM db_gol.tb_prazo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_prazo not in (SELECT id_prazo FROM db_gol.tb_prazo WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    DELETE FROM db_cte.tb_msysparam_cte WHERE id_empresa = $DLPD_NO_ZEROS;

    INSERT INTO db_cte.tb_msysparam_cte(
                id_empresa, tx_versao_layout_cte, nu_formato_impressao, nu_forma_emissao, 
                nu_tipo_ambiente, nu_versao_sistema, id_pessoa_tomador_padrao, 
                id_pessoa_remetente_padrao, id_pessoa_expedidor_padrao, id_pessoa_recebedor_padrao, 
                id_pessoa_destinatario_padrao, dt_inc, dt_atu, tx_login, nu_cfop_dentro, 
                nu_cfop_fora, nu_modelo, nu_serie_cte, tx_observacao_padrao, 
                nu_rntrc, tx_apolice, tx_nome_seguradora, nu_perc_icms)
    (SELECT $DLPD_NO_ZEROS, tx_versao_layout_cte, nu_formato_impressao, nu_forma_emissao, 
        nu_tipo_ambiente, nu_versao_sistema, id_pessoa_tomador_padrao, 
        id_pessoa_remetente_padrao, id_pessoa_expedidor_padrao, id_pessoa_recebedor_padrao, 
        id_pessoa_destinatario_padrao, dt_inc, dt_atu, tx_login, nu_cfop_dentro, 
        nu_cfop_fora, nu_modelo, nu_serie_cte, tx_observacao_padrao, 
        nu_rntrc, tx_apolice, tx_nome_seguradora, nu_perc_icms
    FROM db_cte.tb_msysparam_cte WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

    INSERT INTO db_gol.tb_sit_tributaria(
                aliquota_credito_csosn, csosn, cst, cst_fora, descricao, dt_atu, 
                dt_inc, id_empresa, id_sit_tributaria, login, modalidade_subs, 
                msg_info_adic, msg_info_adic_fora, per_icms, per_icms_subs, per_iss, 
                per_mva, per_red_bcicms_subs, per_red_iss, per_reducao_bcicms, 
                per_reducao_bcicms_fora, vr_credito_csosn, perc_ret_cofins, perc_ret_csll, 
                perc_ret_irrf, perc_ret_pis, perc_ret_prev, tx_cod_aliq_personalizado, 
                perc_ret_iss, cfop_dentro, cfop_fora, per_icms_fora, perc_prev, 
                perc_irrf, tx_cod_irrf, perc_csll, per_icms_diferenciado, lo_isento_base_iss)
    (SELECT aliquota_credito_csosn, csosn, cst, cst_fora, descricao, dt_atu, 
        dt_inc, $DLPD_NO_ZEROS, id_sit_tributaria, login, modalidade_subs, 
        msg_info_adic, msg_info_adic_fora, per_icms, per_icms_subs, per_iss, 
        per_mva, per_red_bcicms_subs, per_red_iss, per_reducao_bcicms, 
        per_reducao_bcicms_fora, vr_credito_csosn, perc_ret_cofins, perc_ret_csll, 
        perc_ret_irrf, perc_ret_pis, perc_ret_prev, tx_cod_aliq_personalizado, 
        perc_ret_iss, cfop_dentro, cfop_fora, per_icms_fora, perc_prev, 
        perc_irrf, tx_cod_irrf, perc_csll, per_icms_diferenciado, lo_isento_base_iss
    FROM db_gol.tb_sit_tributaria WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL and id_sit_tributaria not in (SELECT id_sit_tributaria FROM db_gol.tb_sit_tributaria WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_notfat_justificativa(
                id_empresa, id_justificativa, tx_justificativa, login, dt_inc, 
                dt_atul)
        (SELECT $DLPD_NO_ZEROS, id_justificativa, tx_justificativa, login, dt_inc, 
        dt_atul
    FROM db_gol.tb_notfat_justificativa WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_justificativa not in (SELECT id_justificativa FROM db_gol.tb_notfat_justificativa WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_cfop(
    SELECT id_cfop, descricao, dt_inc, dt_atu, login, isento, lo_atu_stq, 
        lo_atu_fin, $DLPD_NO_ZEROS
    FROM db_gol.tb_cfop WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_cfop not in (SELECT id_cfop FROM db_gol.tb_cfop WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_icms_uf (
    SELECT $DLPD_NO_ZEROS, id_uf, perc_icms, dt_inc, dt_atu, login
    FROM db_gol.tb_icms_uf WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_uf not in (SELECT id_uf FROM db_gol.tb_icms_uf WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_plano_conta(
                id_empresa, id_plano_conta, desc_plano_conta, sintetico, dt_inc, 
                dt_atu, login, lo_visualiza_balancete, lo_tipo_plano_conta)
        (SELECT $DLPD_NO_ZEROS, id_plano_conta, desc_plano_conta, sintetico, dt_inc, 
        dt_atu, login, lo_visualiza_balancete, lo_tipo_plano_conta
    FROM db_gol.tb_plano_conta WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND id_plano_conta not in (SELECT id_plano_conta FROM db_gol.tb_plano_conta WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_aplicacao_grupo(
    SELECT codigo, nome, $DLPD_NO_ZEROS
    FROM db_gol.tb_aplicacao_grupo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL AND codigo not in (SELECT codigo FROM db_gol.tb_aplicacao_grupo WHERE id_empresa = $DLPD_NO_ZEROS)
    );

    INSERT INTO db_gol.tb_atalho (
    SELECT id_nome_apl, $DLPD_NO_ZEROS, tx_descricao, tx_icone, tx_ativo, dt_inc, 
        dt_atu, login
    FROM db_gol.tb_atalho WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

    INSERT INTO db_gol.tb_atalho_grupo (
    SELECT id_atalho_grupo, $DLPD_NO_ZEROS, tx_descricao, dt_inc, dt_atu, login, 
        tx_ativo
    FROM db_gol.tb_atalho_grupo WHERE id_empresa = $DLPD_NO_ZEROS_PRINCIPAL);

    INSERT INTO db_gol.tb_atalho_grupo_item (
    SELECT $DLPD_NO_ZEROS, id_atalho_grupo, id_nome_apl, dt_inc, dt_atu, login
    FROM db_gol.tb_atalho_grupo_item WHERE id_empresa =  $DLPD_NO_ZEROS_PRINCIPAL);
SQL
EOF
}

export -f insere_contrato_multiempresa
export -f executa_script_multiempresa