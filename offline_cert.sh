# 这里创建出来的中间证书都有问题，不具备CA的属性，不能用于验证签名
# Move to root directory...
# cd /
rm cert -rf
mkdir certs
cd certs

# Generate a self signed certificate for the CA along with a key.
mkdir -p root/private
chmod 700 root/private

### ==================自签证书root
# root ca self signed certificate
openssl req \
    -x509 \
    -nodes \
    -days 3650 \
    -newkey rsa:4096 \
    -keyout root/private/root_key.pem \
    -out root/root_cert.crt \
    -subj "/L=Shenzhen/C=CN/O=ABB/OU=OIC/CN=ABB OIC DaaS Root CA"


### ====================msp issuing ca
# Create msp private key and certificate request
mkdir -p msp/private
chmod 700 msp/private
openssl genrsa -out msp/private/msp_key.pem 4096
openssl req -new \
    -key msp/private/msp_key.pem \
    -out msp/msp.csr \
    -subj "/L=Shenzhen/C=CN/O=ABB/OU=OIC/CN=ABB OIC MSP ISSUING CA"

# Generate certificates
openssl x509 -req -days 1460 -in msp/msp.csr \
    -CA root/root_cert.crt -CAkey root/private/root_key.pem \
    -CAcreateserial -out msp/msp_cert.crt

cat root/root_cert.crt >> msp/msp_cert.crt


### =================device1 ca
# Create device1 private key and certificate request
mkdir -p device1/private
chmod 700 device1/private
openssl genrsa -out device1/private/device1_key.pem 4096
openssl req -new \
    -key device1/private/device1_key.pem \
    -out device1/device1.csr \
    -subj "/CN=2333dfe1-236c-42f7-bf02-d15c0bde8358"

# Generate certificates
openssl x509 -req -days 1460 -in device1/device1.csr \
    -CA msp/msp_cert.crt -CAkey msp/private/msp_key.pem \
    -CAcreateserial -out device1/device1_cert.crt

cat msp/msp_cert.crt >> device1/device1_cert.crt

###============= device1 for user1 ca
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

cat device1/device1_cert.crt >> device1ToUser1/device1ToUser1_cert.crt

# # Create client private key and certificate request
# mkdir -p client/private
# chmod 700 client/private
# openssl genrsa -out client/private/client_key.pem 4096
# openssl req -new \
#     -key client/private/client_key.pem \
#     -out client/client.csr \
#     -subj "/C=US/ST=Acme State/L=Acme City/O=Acme Inc./CN=client.example.com"



# # Generate certificates
# openssl x509 -req -days 1460 -in server/server.csr \
#     -CA ca/ca_cert.pem -CAkey ca/private/ca_key.pem \
#     -CAcreateserial -out server/server_cert.pem
# openssl x509 -req -days 1460 -in client/client.csr \
#     -CA ca/ca_cert.pem -CAkey ca/private/ca_key.pem \
#     -CAcreateserial -out client/client_cert.pem

# # Now test both the server and the client
# # On one shell, run the following
# openssl s_server -CAfile ca/ca_cert.pem -cert server/server_cert.pem -key server/private/server_key.pem -Verify 1
# # On another shell, run the following
# openssl s_client -CAfile ca/ca_cert.pem -cert client/client_cert.pem -key client/private/client_key.pem
# # Once the negotiation is complete, any line you type is sent over to the other side.
# # By line, I mean some text followed by a keyboard return press.