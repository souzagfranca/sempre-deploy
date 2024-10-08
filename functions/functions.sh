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

valida_dlpd_tamanho() {

    local dlpd_local="$1"

    if [[ ! $dlpd_local =~ ^[0-9]{6}$ ]]; then
        echo -e "${RED}❌Erro: Código DLPD inválido. O código DLPD deve conter exatamente 6 dígitos numéricos.${RESET}"
        return 1
    fi
    return 0
}

verifica_quantidade_de_caracteres() {

    local minha_string=$1
    local tamanho=${#minha_string}

    if [[ $tamanho -gt 30 ]]; then
        echo -e "${RED}❌Erro: Link inválido. Contém mais de 30 caracteres.${RESET}"
        return 1
    fi
    return 0
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

verifica_se_existe_o_dlpd_no_intranet() {

    local RESULT
    local DLPD_LOCAL="$1"

    SELECT_DLPD="
        SELECT 
	        id_pessoa || ' - ' ||TRIM(REGEXP_REPLACE(tx_razao_social, '[;(),\[\]{}]', '', 'g')) AS tx_razao_social 
        FROM db_ar.tb_pessoa
        WHERE id_pessoa=$DLPD_LOCAL
    "

    RESULT=$(psql -U postgres -d $DB_INTRANET -t -c "$SELECT_DLPD")

    if [[ -z "$RESULT" ]]; then
        echo -e "${RED}❌Erro: O DLPD informado não se encontra na base de dados da Sempre Tecnologia.${RESET}"
        return 1
    else
        RAZAO_SOCIAL="$RESULT"
        return 0
    fi
}

export -f layout
export -f valida_dlpd_tamanho
export -f escolhe_servidor
export -f escolhe_produto
export -f verifica_se_existe_o_dlpd_no_intranet
