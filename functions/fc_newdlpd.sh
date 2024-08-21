source ./config/var.sh

layout() {
    echo -e
    echo -e "                 ${YELLOW}• SempreDeploy Installer v1.0 •${RESET}"
    echo -e "           (Sistema de Instalação da Sempre Tecnologia)"
    echo -e
    echo -e " ${GREEN}Bem-vindo ao SempreDeploy, o instalador oficial dos sistemas da Sempre${RESET}"
    echo -e " ${GREEN}Tecnologia! Este script foi projetado para facilitar a instalação e${RESET}"
    echo -e " ${GREEN}configuração dos sistemas, garantindo que tudo seja feito de forma rápida${RESET}"
    echo -e " ${GREEN}e eficiente.${RESET}"
    echo -e
    echo -e " ${YELLOW}Atenção: Cada vez que o SempreDeploy solicitar que você entre com algum${RESET}"
    echo -e " ${YELLOW}dado, seja cauteloso ao inserir. Preste atenção nos exemplos fornecidos,${RESET}"
    echo -e " ${YELLOW}pois é crucial que você insira os dados corretos para que o SempreDeploy${RESET}"
    echo -e " ${YELLOW}possa subir a aplicação com excelência.${RESET}"
    echo -e
    echo -e
}

valida_dlpd() {
    local DLPD="$1"
    if [[ ! $DLPD =~ ^[0-9]{6}$ ]]; then
        echo -e "${VERMELHO}Erro:${NC} Código DLPD inválido. O código DLPD deve conter exatamente 6 dígitos numéricos."
        exit 1
    fi
}

escolhe_servidor() {

    declare -A servers=(
        ["stapp01"]="172.16.1.170"
        ["stapp06"]="172.16.1.74"
        ["stapp08"]="172.16.1.230"
        ["stapp12"]="172.16.1.38"
        ["stapp15"]="172.16.1.215"
        ["stapp16"]="172.16.1.9"
        ["stapp17"]="172.16.1.129"
        ["stapp18"]="172.16.1.69"
        ["stapp20"]="172.16.1.130"
        ["stapp21"]="172.16.1.19"
        ["stapp23"]="172.16.1.100"
        ["stapp24"]="172.16.1.136"
        ["stapp25"]="172.16.1.7"
        ["stapp26"]="172.16.1.219"
    )

    select server in "${!servers[@]}"; do
        if [[ -n "$server" ]]; then
            HOST_ADDRESS="${servers[$server]}"
            return 0
            break
        else
            return 1
        fi
    done
}

altera_inc_empresa() {
    ssh sempre@$HOST_ADDRESS <<EOF
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

escolhe_produto() {

    declare -A bases=(
        ["Sempre Emissor"]="db_instalacao"
        ["Sempre Lite Produto"]="db_instalacaolite"
        ["Sempre Lite Serviço"]="db_instalacaolitenfse"
        ["Sempre Gestor Produto"]="db_instalacaogestor"
        ["Sempre Gestor Serviço"]="db_instalacaogestornfse"
        ["Sempre BPO Cliente"]="db_instalacaobpocliente"
        ["Sempre BPO Mensalidade"]="db_instalacaobpomensalidade"
        ["Sempre BPO Painel"]="db_instalacaobpopainel"
        ["Sempre Distribuidor"]="db_instalacaodistribuidor"
        ["Sempre Distribuidor Lite"]="db_instalacaolitedistribuidor"
        ["Sempre Mensalidade"]="db_instalacaomensalidade"
        ["Sempre PDV"]="db_instalacaopdv"
        ["Sempre Start"]="db_instalacaostart"
        ["Sempre Vest Gestor"]="db_instalacaovestgestor"
        ["Sempre Vest Lite"]="db_instalacaovestlite"
    )

    echo "Escolha o produto do DLPD $DLPD:"
    select produto in "${!bases[@]}"; do
        if [[ -n "$produto" ]]; then
            PROD_SELECTED="${bases[$produto]}"
            return 0
            break
        else
            return 1
        fi
    done
}

rollback() {
    ssh sempre@$HOST_ADDRESS <<EOF
    rm -r /var/www/html/sempre/_lib/file/doc/$DLPD
    rm -r /var/www/html/sempre/_lib/file/img/$DLPD
    rm -r /var/www/html/sempre/_FISCAL/$DLPD
EOF
}

rollback_db() {
    ssh sempre@$HOST_ADDRESS <<EOF
    psql -U postgres -c "DROP DATABASE IF EXISTS db_$DLPD;"
    rm -f /tmp/${PROD_SELECTED}_backup.dump
EOF
}

cria_pastas() {
    ssh sempre@$HOST_ADDRESS <<EOF
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
    ssh sempre@172.16.1.19 <<EOF
    rm -r /var/www/html/backups/${PROD_SELECTED}_backup.dump
EOF
}

cria_db() {
    ssh sempre@172.16.1.19 <<EOF
    pg_dump -U postgres -Fc $PROD_SELECTED -f /tmp/${PROD_SELECTED}_backup.dump
    mv /tmp/${PROD_SELECTED}_backup.dump /var/www/html/backups/
EOF
    ssh sempre@$HOST_ADDRESS <<EOF
    wget http://172.16.1.19/backups/${PROD_SELECTED}_backup.dump -O /tmp/${PROD_SELECTED}_backup.dump
    psql -U postgres -c "CREATE DATABASE db_$DLPD WITH OWNER postgres;"
    pg_restore -U postgres -d db_$DLPD /tmp/${PROD_SELECTED}_backup.dump
    rm -f /tmp/${PROD_SELECTED}_backup.dump
EOF
    remove_backup_stapp21
}

export -f layout
export -f valida_dlpd
export -f escolhe_servidor
export -f altera_inc_empresa
export -f escolhe_produto
export -f cria_pastas
export -f cria_db