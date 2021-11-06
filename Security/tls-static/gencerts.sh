#!/bin/bash -e

function usage() {
    >&2 cat << EOF
Usage: ./envoy-certs-gen.sh
Set the following environment variables to run this script:
    BASE_DOMAIN     Base domain name of the cluster. For example if your API
                    server is running on "my-cluster-k8s.example.com", the
                    base domain is "example.com"
    CA_CERT(optional)         Path to the pem encoded CA certificate of your cluster.
    CA_KEY(optional)          Path to the pem encoded CA key of your cluster.
EOF
    exit 1
}

BASE_DOMAIN=ilinux.io

if [ -z $BASE_DOMAIN ]; then
    usage
fi

export DIR="certs"
if [ $# -eq 1 ]; then
    DIR="$1"
fi

export CERT_DIR=$DIR
[ ! -e $CERT_DIR ] && mkdir -p $CERT_DIR

CA_CERT="$CERT_DIR/CA/ca.crt"
CA_KEY="$CERT_DIR/CA/ca.key"

# Configure expected OpenSSL CA configs.

touch $CERT_DIR/index
touch $CERT_DIR/index.txt
touch $CERT_DIR/index.txt.attr
echo 1000 > $CERT_DIR/serial
# Sign multiple certs for the same CN
echo "unique_subject = no" > $CERT_DIR/index.txt.attr

function openssl_req() {
    openssl genrsa -out ${1}/${2}.key 2048
    echo "Generating ${1}/${2}.csr"
    openssl req -config openssl.conf -new -sha256 \
        -key ${1}/${2}.key -out ${1}/${2}.csr -subj "$3"
}

function openssl_sign() {
    echo "Generating ${3}/${4}.crt"
    openssl ca -batch -config openssl.conf -extensions ${5} -days 3650 -notext \
        -md sha256 -in ${3}/${4}.csr -out ${3}/${4}.crt \
        -cert ${1} -keyfile ${2}
}

if [ ! -e "$CA_KEY" -o ! -e "$CA_CERT" ]; then
    mkdir $CERT_DIR/CA
    openssl genrsa -out $CERT_DIR/CA/ca.key 4096
    openssl req -config openssl.conf \
        -new -x509 -days 3650 -sha256 \
        -key $CERT_DIR/CA/ca.key -extensions v3_ca \
        -out $CERT_DIR/CA/ca.crt -subj "/CN=envoy-ca"
    export CA_KEY="$CERT_DIR/CA/ca.key"
    export CA_CERT="$CERT_DIR/CA/ca.crt"
fi

read -p "Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): " CERT EXT
while [ -n "$CERT" -a -n "$EXT" ]; do
    [ ! -e $CERT_DIR/$CERT ] && mkdir $CERT_DIR/$CERT
    if [ "$EXT" == "envoy_server_cert" ]; then 
        openssl_req $CERT_DIR/$CERT server "/CN=$CERT"
        openssl_sign $CERT_DIR/CA/ca.crt $CERT_DIR/CA/ca.key $CERT_DIR/$CERT server $EXT
    else
        openssl_req $CERT_DIR/$CERT client "/CN=$CERT"
        openssl_sign $CERT_DIR/CA/ca.crt $CERT_DIR/CA/ca.key $CERT_DIR/$CERT client $EXT
    fi
    read -p "Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): " CERT EXT
done

# Add debug information to directories
#for CERT in $CERT_DIR/*; do
#    [ -d $CERT ] && openssl x509 -in $CERT/*.crt -noout -text > "${CERT%.crt}.txt"
#done

# Clean up openssl config
rm $CERT_DIR/index*
rm $CERT_DIR/100*
rm $CERT_DIR/serial*
for CERT in $CERT_DIR/*; do
    [ -d $CERT ] && rm -f $CERT/*.csr
done
