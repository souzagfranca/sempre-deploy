source ./config/var.sh
source ./functions/fc_newdlpd.sh
source ./functions/fc_database.sh

layout

read -p "Digite o número do DLPD (Ex: 001234/012345): " DLPD
valida_dlpd "$DLPD"
DLPD_NO_ZEROS=$(echo $DLPD | sed 's/^0*//')
echo

read -p "Digite o link criado na AWS (Ex: sempre): " LINK
echo

escolhe_servidor
if [ $? -eq 0 ]; then
    echo -e "Você escolheu o servidor ${GREEN}⮞ $server${RESET} com IP $HOST_ADDRESS"
else
    echo "${RED}Opção inválida. Tente novamente. ❌${RESET}"
fi
echo

altera_inc_empresa
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ linha inserida no arquivo inc_empresa.php do servidor $server ✓${RESET}"
else
    echo -e "${RED}Erro ao inserir linha na inc_empresa.php do servidor $server ❌${RESET}"
fi
echo

escolhe_produto
if [ $? -eq 0 ]; then
    echo -e "Você escolheu o produto ${GREEN}⮞ $produto${RESET}"
else
    echo "${RED}Opção inválida. Tente novamente. ❌${RESET}"
fi
echo

cria_pastas
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ Estrutura de pasta concluída com sucesso ✓${RESET}"
else
    echo -e "${RED}Erro ao criar pastas. O processo foi desfeito ❌${RESET}"
    rollback
    exit 1
fi
echo

cria_db
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ Banco de dados criado e restaurado com sucesso ✓${RESET}"
else
    echo -e "${RED}Erro ao criar banco de dados ❌${RESET}"
    rollback
    rollback_db
    exit 1
fi
echo

executa_altera_empresa
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ SQL altera empresa executado com sucesso no banco de dados db_$DLPD ✓${RESET}"
else
    echo -e "${RED}Erro ao executar SQL ❌${RESET}"
    exit 1
fi
echo

insere_contrato
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ Dados inseridos com sucesso na tabela tb_contratos ✓${RESET}"
else
    echo -e "${RED}Erro ao inserir na contratos ❌${RESET}"
    exit 1
fi
echo

insere_dados_DLPD
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ Dados do intranet inserido na tb_empresa ✓${RESET}"
else
    echo -e "${RED}Erro ao inserir dados ❌${RESET}"
    exit 1
fi
echo

atualiza_licenca_axm
if [ $? -eq 0 ]; then
    echo -e "${GREEN}⮞ DLPD ativado no AXM ✓${RESET}"
else
    echo -e "${RED}Erro ao ativar DLPD ❌${RESET}"
    exit 1
fi
echo

echo -e "${GREEN}⮞ DLPD $DLPD_NO_ZEROS instalado com sucesso! ✓${RESET}"