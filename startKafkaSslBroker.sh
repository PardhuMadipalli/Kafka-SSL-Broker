#!/bin/bash

MY_WEBSITE=www.mywebsite.com
MY_PASSWORD=mypassword


if [[ -z $KAFKA_HOME ]]; then
	echo "KAFKA_HOME must be set"
	exit
fi


cp $(dirname "$(readlink -f $0)")/serverssl.properties $KAFKA_HOME/config/serverssl.properties

if [[ -d "/tmp/kafka-logs-ssl" ]]; then
	rm -Rf /tmp/kafka-logs-ssl
fi


if [[ -d "${KAFKA_HOME}/ssl/" ]]; then
	echo "ssl config already exists. Setting keystore location to $KAFKA_HOME/ssl/server.keystore.jks"

else

mkdir -p $KAFKA_HOME/ssl/
cd $KAFKA_HOME/ssl/


keytool -keystore server.keystore.jks -alias $MY_WEBSITE -validity 365 -genkey -keyalg RSA -dname "CN=$MY_WEBSITE, OU=orgunit, O=Organisation, L=bangalore, S=Karnataka, C=IN" -ext SAN=DNS:$MY_WEBSITE -keypass $MY_PASSWORD -storepass $MY_PASSWORD && \
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -passout pass:"$MY_PASSWORD" -subj "/CN=$MY_WEBSITE" && \
keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert -storepass $MY_PASSWORD -noprompt && \
keytool -keystore server.keystore.jks -alias $MY_WEBSITE -certreq -file cert-file -storepass $MY_PASSWORD && \
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:$MY_PASSWORD && \
keytool -keystore server.keystore.jks -alias $MY_WEBSITE -import -file cert-signed -storepass $MY_PASSWORD

fi

cd $KAFKA_HOME
KAFKA_SSL_DIR="${KAFKA_HOME}/ssl"
echo $KAFKA_SSL_DIR

sed -i "s|<WEBSITE>|${MY_WEBSITE}|g" ./config/serverssl.properties
sed -i "s|<PASSWORD>|${MY_PASSWORD}|g" ./config/serverssl.properties
sed -i "s|<DIRNAME>|${KAFKA_SSL_DIR}|g" ./config/serverssl.properties

$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/serverssl.properties && \
echo -e "***	SSL listener runs on port 9093, PLAINTEXT listener runs on port 9094	***"
echo -e "following process runs at 9093 \nusing netstat -tulnp | grep 9093"
netstat -tulnp | grep 9093
