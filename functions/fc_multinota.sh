source ./config/var.sh

cria_pasta_multinota(){
    ssh sempre@$HOST_ADDRESS <<EOF
    cp -r /var/www/html/sempre/_lib/file/doc/009000inst /var/www/html/sempre/_lib/file/doc/$DLPD
    cp -r /var/www/html/sempre/_lib/file/img/009000inst /var/www/html/sempre/_lib/file/img/$DLPD
    chmod -Rf 777 /var/www/html/sempre/_lib/file/doc/$DLPD
    chmod -Rf 777 /var/www/html/sempre/_lib/file/img/$DLPD

    cd /var/www/html/sempre/_FISCAL/009000inst
    cp -r * /var/www/html/sempre/_FISCAL/$DLPD_PRINCIPAL
    cd /var/www/html/sempre/_FISCAL/$DLPD_PRINCIPAL
    rename 's/9000/${DLPD_NO_ZEROS}/' CTE9000 MDFE9000 NFCE9000 NFE9000 NFSE9000 tmp9000
    chmod -Rf 777 /var/www/html/sempre/_FISCAL/$DLPD
EOF
}

insere_new_empresa() {
    ssh sempre@$HOST_ADDRESS <<EOF
    psql -U postgres -d db_00$DLPD_PRINCIPAL << 'SQL'
    
SQL
EOF
}