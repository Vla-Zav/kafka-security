cp common/ca.cnf .

apt update && apt install -y openssl openjdk-11-jre-headless

openssl req -new -nodes \
   -x509 \
   -days 365 \
   -newkey rsa:2048 \
   -keyout ca.key \
   -out ca.crt \
   -config ca.cnf

cat ca.crt ca.key > ca.pem

openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-1-creds/kafka-1.key \
    -out kafka-1-creds/kafka-1.csr \
    -config kafka-1-creds/kafka-1.cnf \
    -nodes

openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-2-creds/kafka-2.key \
    -out kafka-2-creds/kafka-2.csr \
    -config kafka-2-creds/kafka-2.cnf \
    -nodes

openssl req -new \
    -newkey rsa:2048 \
    -keyout kafka-3-creds/kafka-3.key \
    -out kafka-3-creds/kafka-3.csr \
    -config kafka-3-creds/kafka-3.cnf \
    -nodes



openssl x509 -req \
    -days 3650 \
    -in kafka-1-creds/kafka-1.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-1-creds/kafka-1.crt \
    -extfile kafka-1-creds/kafka-1.cnf \
    -extensions v3_req

openssl x509 -req \
    -days 3650 \
    -in kafka-2-creds/kafka-2.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-2-creds/kafka-2.crt \
    -extfile kafka-2-creds/kafka-2.cnf \
    -extensions v3_req

openssl x509 -req \
    -days 3650 \
    -in kafka-3-creds/kafka-3.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out kafka-3-creds/kafka-3.crt \
    -extfile kafka-3-creds/kafka-3.cnf \
    -extensions v3_req


openssl pkcs12 -export \
    -in kafka-1-creds/kafka-1.crt \
    -inkey kafka-1-creds/kafka-1.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-1 \
    -out kafka-1-creds/kafka-1.p12 \
    -password pass:password

openssl pkcs12 -export \
    -in kafka-2-creds/kafka-2.crt \
    -inkey kafka-2-creds/kafka-2.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-2 \
    -out kafka-2-creds/kafka-2.p12 \
    -password pass:password

openssl pkcs12 -export \
    -in kafka-3-creds/kafka-3.crt \
    -inkey kafka-3-creds/kafka-3.key \
    -chain \
    -CAfile ca.pem \
    -name kafka-3 \
    -out kafka-3-creds/kafka-3.p12 \
    -password pass:password



keytool -importkeystore \
    -deststorepass password \
    -destkeystore kafka-1-creds/kafka.kafka-1.keystore.pkcs12 \
    -srckeystore kafka-1-creds/kafka-1.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass password

keytool -importkeystore \
    -deststorepass password \
    -destkeystore kafka-2-creds/kafka.kafka-2.keystore.pkcs12 \
    -srckeystore kafka-2-creds/kafka-2.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass password

keytool -importkeystore \
    -deststorepass password \
    -destkeystore kafka-3-creds/kafka.kafka-3.keystore.pkcs12 \
    -srckeystore kafka-3-creds/kafka-3.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass password


keytool -import \
    -file ca.crt \
    -alias ca \
    -keystore kafka-1-creds/kafka.kafka-1.truststore.jks \
    -storepass password \
     -noprompt

keytool -import \
    -file ca.crt \
    -alias ca \
    -keystore kafka-2-creds/kafka.kafka-2.truststore.jks \
    -storepass password \
     -noprompt

keytool -import \
    -file ca.crt \
    -alias ca \
    -keystore kafka-3-creds/kafka.kafka-3.truststore.jks \
    -storepass password \
     -noprompt


echo "password" > kafka-1-creds/kafka-1_sslkey_creds
echo "password" > kafka-1-creds/kafka-1_keystore_creds
echo "password" > kafka-1-creds/kafka-1_truststore_creds


echo "password" > kafka-2-creds/kafka-2_sslkey_creds
echo "password" > kafka-2-creds/kafka-2_keystore_creds
echo "password" > kafka-2-creds/kafka-2_truststore_creds


echo "password" > kafka-3-creds/kafka-3_sslkey_creds
echo "password" > kafka-3-creds/kafka-3_keystore_creds
echo "password" > kafka-3-creds/kafka-3_truststore_creds


keytool -importkeystore \
    -srckeystore kafka-1-creds/kafka-1.p12 \
    -srcstoretype PKCS12 \
    -destkeystore kafka-1-creds/kafka-1.keystore.jks \
    -deststoretype JKS \
    -deststorepass password

keytool -importkeystore \
    -srckeystore kafka-2-creds/kafka-2.p12 \
    -srcstoretype PKCS12 \
    -destkeystore kafka-2-creds/kafka-2.keystore.jks \
    -deststoretype JKS \
    -deststorepass password

keytool -importkeystore \
    -srckeystore kafka-3-creds/kafka-3.p12 \
    -srcstoretype PKCS12 \
    -destkeystore kafka-3-creds/kafka-3.keystore.jks \
    -deststoretype JKS \
    -deststorepass password


keytool -import -trustcacerts -file ca.crt \
    -keystore kafka-1-creds/kafka-1.truststore.jks \
    -storepass password -noprompt -alias ca

keytool -import -trustcacerts -file ca.crt \
    -keystore kafka-2-creds/kafka-2.truststore.jks \
    -storepass password -noprompt -alias ca

keytool -import -trustcacerts -file ca.crt \
    -keystore kafka-3-creds/kafka-3.truststore.jks \
    -storepass password -noprompt -alias ca