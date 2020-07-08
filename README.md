# Setup kafka broker with SSL


#### Steps to start ssl enabled broker

- Setup KAFKA_HOME envionment variable to the Kafka installation directory. Example `export KAFKA_HOME=/usr/home/kafka_2.11`
- Make sure that there are no other procceses running at port 9093 or 9094.
- Modify MY_WEBSITE in `startkafkaSslBroker.sh` to the domain name of the host where the kafka broker is running.
- Modify MY_PASSWORD to the password to be used while creating SSL certifcates and key stores.
- Run the script using `./startkafkaSslBroker.sh`

### Broker details

- Broker SSL port is 9093 and PLAINTEXT port is 9094
