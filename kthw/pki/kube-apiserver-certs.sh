#209.97.175.94,10.130.87.198,159.89.206.152,10.130.51.214,206.189.146.138,10.130.67.150,206.189.145.40,10.130.76.219,178.128.210.133,10.130.105.221,209.97.172.190,10.130.90.57

KUBERNETES_PUBLIC_ADDRESS=209.97.175.94,10.130.87.198,159.89.206.152,10.130.51.214,206.189.146.138,10.130.67.150,206.189.145.40,10.130.76.219,178.128.210.133,10.130.105.221,209.97.172.190,10.130.90.57

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "SG",
      "L": "Singapore",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Singapore"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes