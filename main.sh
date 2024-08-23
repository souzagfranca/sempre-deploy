source ./config/var.sh
source ./functions/fc_newdlpd.sh
source ./functions/fc_multiempresa.sh
source ./functions/fc_multinota.sh
source ./functions/functions.sh

solicita_dados_caso_multinota_multiempresa() {

    read -p "Qual é o DLPD principal? (Ex: 001234/012345):" DLPD_PRINCIPAL
    valida_dlpd_tamanho "$DLPD_PRINCIPAL"
    DLPD_NO_ZEROS_PRINCIPAL=$(echo $DLPD_PRINCIPAL | sed 's/^0*//')
    verifica_se_existe_o_dlpd_no_intranet "$DLPD_NO_ZEROS_PRINCIPAL"
    echo -e "${YELLOW}DLPD principal: $RAZAO_SOCIAL${RESET}"
    echo

    read -p "Qual é o novo DLPD? (Ex: 001234/012345):" DLPD
    valida_dlpd_tamanho "$DLPD"
    DLPD_NO_ZEROS=$(echo $DLPD | sed 's/^0*//')
    verifica_se_existe_o_dlpd_no_intranet "$DLPD_NO_ZEROS"
    echo -e "${YELLOW}Novo DLPD: $RAZAO_SOCIAL${RESET}"
    echo

    read -p "Qual é o link do DLPD principal? (Ex: sempre):" LINK
    verifica_quantidade_de_caracteres "$LINK"
    echo

    echo -e "${YELLOW}Em qual servidor o DLPD principal $DLPD_NO_ZEROS_PRINCIPAL se encontra?:${RESET}"
    echo
    escolhe_servidor
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ O DLPD principal $DLPD_NO_ZEROS_PRINCIPAL está no servidor ${YELLOW}$server${RESET} com IP $HOST_ADDRESS"
    else
        echo -e "${RED}Opção inválida. Tente novamente. ❌${RESET}"
        exit 1
    fi
    echo
}

regra_para_criar_pastas_novodlpd_e_multiempresa() {

    cria_pastas_para_novo_dlpd
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

    insere_nova_empresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ O novo DLPD $DLPD_NO_ZEROS foi cadastrado no DLPD principal $DLPD_NO_ZEROS_PRINCIPAL ✓${RESET}"
    else
        echo -e "${RED}⮞ Erro ao cadastrar novo DLPD ❌${RESET}"
        exit 1
    fi
    echo
}

fc_instala_novo_dlpd() {

    read -p "Qual é o número do novo DLPD? (Ex: 001234/012345):" DLPD
    valida_dlpd_tamanho "$DLPD"
    DLPD_NO_ZEROS=$(echo $DLPD | sed 's/^0*//')
    verifica_se_existe_o_dlpd_no_intranet "$DLPD_NO_ZEROS"
    echo -e "${YELLOW}Novo DLPD: $RAZAO_SOCIAL${RESET}"
    echo

    read -p "Qual é o link que você criou na AWS para este DLPD? (Ex: sempre):" LINK
    verifica_quantidade_de_caracteres "$LINK"
    echo

    echo -e "${YELLOW}Em qual servidor você deseja instalar o novo DLPD $DLPD_NO_ZEROS:${RESET}"
    echo
    escolhe_servidor
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Você escolheu o servidor ${YELLOW}$server${RESET} ${GREEN}com IP${RESET} $HOST_ADDRESS"
    else
        echo "${RED}⮞ Opção inválida. Tente novamente. ❌${RESET}"
    fi
    echo

    altera_arquivo_inc_empresa
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Empresa inserida no arquivo inc_empresa.php do servidor ${YELLOW}$server${RESET} ✓"
    else
        echo -e "${RED}⮞ Erro ao inserir empresa no arquivo inc_empresa.php do servidor $server ❌${RESET}"
    fi
    echo

    echo -e "${YELLOW}Qual é o produto que o DLPD $DLPD_NO_ZEROS adquiriu?:${RESET}"
    echo
    escolhe_produto
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}⮞ Você escolheu o produto ${YELLOW}$produto${RESET}"
    else
        echo "${RED}⮞ Opção inválida. Tente novamente. ❌${RESET}"
        exit 1
    fi
    echo

    regra_para_criar_pastas_novodlpd_e_multiempresa

    cria_novo_banco_de_dados
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

    atualiza_dados_na_tb_empresa
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

    configura_parametros_multinota
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

    regra_para_criar_pastas_novodlpd_e_multiempresa

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
        ["Cancelar Operação"]="cancelar"
    )

    layout

    echo -e "${YELLOW}Escolha o tipo de instalação:${RESET}"
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
        "cancelar")
            exit 0
            ;;
        *) ;;
        esac
    done

}

executa_tipo_instalacao
