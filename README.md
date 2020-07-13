# Setup kafka broker with SSL

#### Dependencies

- [keytool (Java)](https://www.oracle.com/in/java/technologies/javase/javase-jdk8-downloads.html) (version >= 1.8)
- [openssl](https://www.openssl.org/)
- [Kafka](https://kafka.apache.org/) (Version >= 2.0)

#### Steps before starting

- Setup KAFKA_HOME, DOMAIN and PASSWORD environment variables. 
- KAFKA_HOME example `export KAFKA_HOME=/usr/home/kafka_2.11`
- Properties like Kafka broker ID and zookeeper can be modified in `serverssl.properties` file.
- Make sure that there are no other procceses running at port 9093 or 9094.
- All the ssl related files will be create in `$KAFKA_HOME/ssl` directory.

#### Steps to start Kafka Broker with SSL enabled

- Download the zip file of the repo from [here](https://github.com/PardhuMadipalli/Kafka-SSL-Broker/archive/master.zip).
- Extract the zip using the command `unzip <filename>.zip`
- Run the script using `./startkafkaSslBroker.sh`.

#### Broker details
- Broker SSL port is 9093 and PLAINTEXT port is 9094

##### The script has been verified to run successfully in OracleLinux (>=7)
