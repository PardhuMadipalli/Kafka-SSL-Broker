#!/bin/bash

# Tested on Oracle Linux 7

if [[ -z $KAFKA_HOME ]]; then
	echo "KAFKA_HOME must be set."
	exit 1
fi
if [[ -z $DOMAIN ]]; then
	echo "DOMAIN is not set, using www.mywebsite.com"
	DOMAIN=www.mywebsite.com
fi
if [[ -z $PASSWORD ]]; then
        echo "PASSWORD is not set, using abc123def"
        PASSWORD=abc123def
fi

if [[ -d "/tmp/kafka-logs-ssl" ]]; then
	rm -Rf /tmp/kafka-logs-ssl
fi


if [[ -d "${KAFKA_HOME}/ssl/" ]]; then
    echo "${KAFKA_HOME}/ssl directory already exists."
	read -p "Type Y to delete the ssl/ directory and create new keystore and certificates. Else, enter N to exit: " response
    if [[ "${response}" != "Y" ]]; then
        exit 0
    else
        echo -e "removing ssl/ directory from $KAFKA_HOME\n"
        rm -Rf ${KAFKA_HOME}/ssl/
    fi
fi

mkdir -p $KAFKA_HOME/ssl/
cd $KAFKA_HOME/ssl/

keytool -keystore server.keystore.jks -alias $DOMAIN -validity 365 -genkey -keyalg RSA -dname "CN=$DOMAIN, OU=orgunit, O=Organisation, L=bangalore, S=Karnataka, C=IN" -ext SAN=DNS:$DOMAIN -keypass $PASSWORD -storepass $PASSWORD && \
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -passout pass:"$PASSWORD" -subj "/CN=$DOMAIN" && \
keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert -storepass $PASSWORD -noprompt && \
keytool -keystore server.keystore.jks -alias $DOMAIN -certreq -file cert-file -storepass $PASSWORD && \
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:$PASSWORD && \
keytool -keystore server.keystore.jks -alias $DOMAIN -import -file cert-signed -storepass $PASSWORD

cd $KAFKA_HOME
KAFKA_SSL_DIR="${KAFKA_HOME}/ssl"

cp $(dirname "$(readlink -f $0)")/serverssl.properties $KAFKA_HOME/config/serverssl.properties
sed -i "s|<WEBSITE>|${DOMAIN}|g" ./config/serverssl.properties
sed -i "s|<PASSWORD>|${PASSWORD}|g" ./config/serverssl.properties
sed -i "s|<DIRNAME>|${KAFKA_SSL_DIR}|g" ./config/serverssl.properties

$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/serverssl.properties && \
echo "generated keystore file is ${KAFKA_SSL_DIR}/server.keystore.jks"

echo -e "Following is the ID of the process running at 9093/TCP"
netstat -tulnp | grep 9093
