#!/bin/bash 


/home/software/zookeeper-3.4.6/bin/zkServer.sh  start  > /home/software/zookeeper-3.4.6/logs/zkStart.log
wait 
/home/cassandra/apache-cassandra-3.11.0/bin/cassandra   /home/cassandra/apache-cassandra-3.11.0/logs/cassandraStart.log

wait
/home/software/kafka_2.10-0.10.1.0/bin/kafka-server-start.sh  /home/software/kafka_2.10-0.10.1.0/config/server.properties > /home/software/kafka_2.10-0.10.1.0/logs/startkafkaServer.log

