connect_server() {

    local host=$1
    shift
    ssh sempre@$host "$@"

    if [ $? -ne 0 ]; then
        echo "Erro conectar com o servidor $host."
        return 1
    fi

}

export -f connect_server