# 参考：https://www.cnblogs.com/Black-Hawk/articles/13542307.html
# Move to root directory...
# cd /
rm certs -rf
mkdir certs
cd certs
cp ../demoCA ./demoCA -rf

# Generate a self signed certificate for the CA along with a key.
mkdir -p root/private
chmod 700 root/private

echo "=================== root ca...=================="
# root ca self signed certificate
openssl req \
    -x509 \
    -nodes \
    -days 3650 \
    -newkey rsa:4096 \
    -keyout root/private/root_key.pem \
    -out root/root_cert.crt \
    -subj "/ST=Shenzhen/L=Shenzhen/C=CN/O=ABB/OU=OIC/CN=ABB OIC DaaS Root CA"

echo "=================== msp issuing ca...=================="
# Create msp private key and certificate request
mkdir -p msp/private
chmod 700 msp/private
openssl genrsa -out msp/private/msp_key.pem 4096
openssl req -new \
    -days 3650 \
    -key msp/private/msp_key.pem \
    -out msp/msp.csr \
    -subj "/ST=Shenzhen/L=Shenzhen/C=CN/O=ABB/OU=OIC/CN=ABB OIC MSP ISSUING CA"

# Generate certificates
openssl ca \
    -extensions v3_ca \
    -in msp/msp.csr \
    -days 3650 \
    -out msp/msp_cert.crt \
    -cert root/root_cert.crt \
    -keyfile root/private/root_key.pem


# cat root/root_cert.crt >> msp/msp_cert.crt

echo "=================== device1 ca...=================="
# Create device1 private key and certificate request
mkdir -p device1/private
chmod 700 device1/private
openssl genrsa -out device1/private/device1_key.pem 4096
openssl req -new \
    -days 3650 \
    -key device1/private/device1_key.pem \
    -out device1/device1.csr \
    -subj "/ST=Shenzhen/L=Shenzhen/C=CN/O=ABB/OU=OIC/CN=2333dfe1-236c-42f7-bf02-d15c0bde8358"

# Generate certificates
openssl ca \
    -extensions v3_ca \
    -in device1/device1.csr \
    -days 3650 \
    -out device1/device1_cert.crt \
    -cert msp/msp_cert.crt  \
    -keyfile msp/private/msp_key.pem

# cat msp/msp_cert.crt >> device1/device1_cert.crt

echo "=================== device1 for user1 ca...=================="
# Create device1ToUser1 private key and certificate request
mkdir -p device1ToUser1/private
chmod 700 device1ToUser1/private
openssl genrsa -out device1ToUser1/private/device1ToUser1_key.pem 4096
openssl req -new \
    -key device1ToUser1/private/device1ToUser1_key.pem \
    -out device1ToUser1/device1ToUser1.csr \
    -subj "/O=CNDEX@ABB.com.cn/OU=OIC/L=shenzhen/D=guangdong/C=CN/CN=2333dfe1-236c-42f7-bf02-d15c0bde8359"

# Generate certificates
openssl x509 -req -days 1460 -in device1ToUser1/device1ToUser1.csr \
    -CA device1/device1_cert.crt -CAkey device1/private/device1_key.pem \
    -CAcreateserial -out device1ToUser1/device1ToUser1_cert.crt

# cat device1/device1_cert.crt >> device1ToUser1/device1ToUser1_cert.crt
