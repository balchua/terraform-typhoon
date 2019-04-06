#!/bin/bash


declare -A externalIps=( ["kube-worker-0"]="159.89.206.152" ["kube-worker-1"]="178.128.210.133" ["kube-worker-2"]="206.189.146.138")

declare -A internalIps=( ["kube-worker-0"]="10.130.51.214" ["kube-worker-1"]="10.130.105.221" ["kube-worker-2"]="10.130.67.150" )

for instance in kube-worker-0 kube-worker-1 kube-worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "SG",
      "L": "Singapore",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Singapore"
    }
  ]
}
EOF

#echo "${externalIps[kube-worker-0]}"
EXTERNAL_IP=${externalIps[$instance]}

echo $EXTERNAL_IP

INTERNAL_IP=${internalIps[$instance]}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}

done