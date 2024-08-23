source ./config/var.sh
source ./functions/fc_newdlpd.sh
source ./functions/fc_multiempresa.sh
source ./functions/fc_multinota.sh
source ./functions/functions.sh

solicita_dados_caso_multinota_multiempresa() {
    read -p "Digite o número do DLPD principal (Ex: 001234/012345): " DLPD_PRINCIPAL
    valida_dlpd_caracteres_e_cria_variavel_sem_zeros "$DLPD_PRINCIPAL"
    verifica_se_existe_o_dlpd_no_intranet "$DLPD_PRINCIPAL"
    echo -e "DLPD principal: ${GREEN}$RAZAO_SOCIAL${RESET}"
    echo

    read -p "Digite o número do novo DLPD (Ex: 001234/012345): " DLPD
    valida_dlpd_caracteres_e_cria_variavel_sem_zeros "$DLPD"
    verifica_se_existe_o_dlpd_no_intranet "$DLPD"
    echo -e "Novo DLPD: ${GREEN}$RAZAO_SOCIAL${RESET}"
    echo

    read -p "Digite o link do DLPD principal (Ex: sempre): " LINK
    echo

    echo "Em qual servidor o DLPD principal $DLPD_PRINCIPAL se encontra?:"
    escolhe_servidor
    if [ $? -eq 0 ]; then
        echo -e "O DLPD principal $DLPD_PRINCIPAL está no servidor ${GREEN}⮞ $server${RESET} com IP $HOST_ADDRESS"
    else
        echo -e "${RED}Opção inválida. Tente novamente. ❌${RESET}"
        exit 1
    fi
    echo
}

cria_pastas_novodlpd_multiempresa() {
    cria_pastas
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Estrutura de pasta concluída com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao criar pastas. O processo foi desfeito ❌${RESET}"
        rollback
        exit 1
    fi
    echo
}

atualiza_axm_para_todos_tipos() {
    atualiza_licenca_axm
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Licença do novo DLPD $DLPD_NO_ZEROS atualizado com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao atualizar licença ❌${RESET}"
        exit 1
    fi
    echo
}

cadastra_nova_empresa_caso_multinota_multiempresa() {
    insere_new_empresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ O novo DLPD $DLPD_NO_ZEROS foi cadastrado no DLPD principal $DLPD_NO_ZEROS_PRINCIPAL ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao cadastrar novo DLPD ❌${RESET}"
        exit 1
    fi
    echo
}

fc_instala_novo_dlpd() {
    read -p "Qual o número do novo DLPD? (Ex: 001234/012345): " DLPD
    valida_dlpd_caracteres_e_cria_variavel_sem_zeros "$DLPD"
    verifica_se_existe_o_dlpd_no_intranet "$DLPD"
    echo -e "Novo DLPD: ${GREEN}$RAZAO_SOCIAL${RESET}"
    echo

    read -p "Digite o link criado na AWS (Ex: sempre): " LINK
    echo

    echo "Escolha o servidor onde deseja instalar o DLPD $DLPD_NO_ZEROS:"
    escolhe_servidor
    if [ $? -eq 0 ]; then
        echo -e "Você escolheu o servidor ${GREEN}⮞ $server${RESET} com IP $HOST_ADDRESS"
    else
        echo "${RED}⮞ Opção inválida. Tente novamente. ❌${RESET}"
    fi
    echo

    altera_inc_empresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ linha inserida no arquivo inc_empresa.php do servidor $server ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao inserir linha na inc_empresa.php do servidor $server ❌${RESET}"
    fi
    echo

    escolhe_produto
    if [ $? -eq 0 ]; then
        echo -e "Você escolheu o produto ${GREEN}⮞ $produto${RESET}"
    else
        echo "${RED}⮞ Opção inválida. Tente novamente. ❌${RESET}"
    fi
    echo

    cria_pastas_novodlpd_multiempresa

    cria_db
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Banco de dados criado e restaurado com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao criar e restaurar backup no banco de dados ❌${RESET}"
        rollback
        rollback_db
        exit 1
    fi
    echo

    executa_altera_empresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ SQL altera empresa executado com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao executar SQL ❌${RESET}"
        exit 1
    fi
    echo

    insere_contrato
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Empresa inserida com sucesso na contratos ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao inserir na contratos ❌${RESET}"
        exit 1
    fi
    echo

    insere_dados_DLPD
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Dados do intranet cadastrados com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao cadastrar dados ❌${RESET}"
        exit 1
    fi
    echo

    atualiza_axm_para_todos_tipos

    echo -e "${GREEN}⮞ Novo DLPD $DLPD_NO_ZEROS instalado com sucesso! ✓${RESET}"
}

fc_instala_multinota() {

    solicita_dados_caso_multinota_multiempresa

    cria_pasta_multinota
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Estrutura de pasta multinota criada com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao criar pastas ❌${RESET}"
        exit 1
    fi
    echo

    cadastra_nova_empresa_caso_multinota_multiempresa

    executa_script_multinota
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ SQL multinota executado com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao executar o SQL multinota ❌${RESET}"
        exit 1
    fi
    echo

    config_parametros_multinota
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Parâmetros para multinota configurados ✓${RESET}"
    else
        echo -e "${RED}⮞ Parâmetros não configurados ❌${RESET}"
        exit 1
    fi
    echo

    atualiza_axm_para_todos_tipos

    echo -e "${GREEN}⮞ O novo DLPD $DLPD foi instalado com sucesso no DLPD principal $DLPD_PRINCIPAL ✓${RESET}"

}

fc_instala_multiempresa() {

    solicita_dados_caso_multinota_multiempresa

    cria_pastas_novodlpd_multiempresa

    cadastra_nova_empresa_caso_multinota_multiempresa

    executa_script_multiempresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ SQL multiempresa executado com sucesso ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao executar SQL multiempresa ❌${RESET}"
        exit 1
    fi
    echo

    insere_contrato_multiempresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Empresa inserida com sucesso na contratos ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao inserir empresa na contratos ❌${RESET}"
        exit 1
    fi
    echo

}

executa_tipo_instalacao() {

    declare -A tipo_instalacao=(
        ["Novo DLPD"]="novo_dlpd"
        ["Multi Nota"]="multi_nota"
        ["Multi Empresa"]="multi_empresa"
    )

    layout

    echo "Escolha o tipo de instalação:"
    select tipo in "${!tipo_instalacao[@]}"; do
        vlr_tipo=${tipo_instalacao[$tipo]}

        case $vlr_tipo in
        "novo_dlpd")
            fc_instala_novo_dlpd
            break
            ;;
        "multi_nota")
            fc_instala_multinota
            break
            ;;
        "multi_empresa")
            fc_instala_multiempresa
            break
            ;;
        *) ;;
        esac
    done

}

executa_tipo_instalacao