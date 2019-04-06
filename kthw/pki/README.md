## Doctl stuffs
    doctl compute droplet list --format "ID,Name,PublicIPv4,PrivateIPv4"
    doctl compute image list --public #get all the image names such as ubuntu-18-04-x64"
    doctl compute size list

  // Still trying this one out.  DO not use this command
  
    doctl compute size list -o json | jq ' .[] | select (.slug == "s-32vcpu-192gb") | {memory}' | eval "$(jq -r '@sh "export TEST_MEM=\(.memory); echo $TEST_MEM "')"
    


# Generate the ca cert

`cfssl gencert -initca ca-csr.json | cfssljson -bare ca`

Will produce the following files:

    ca.pem
    ca-key.pem

# Generate the Admin client certificates

Use the ca generated certs to sign the

    cfssl gencert \
       -ca=ca.pem \
       -ca-key=ca-key.pem \
       -config=ca-config.json \
       -profile=kubernetes \
       admin-csr.json | cfssljson -bare admin


Will produce the following files:

    admin.pem
    admin-key.pem


#Generate kubelet client certificates

Get the worker external and internal IP first.

    export EXTERNAL_IP=178.128.126.32
    export INTERNAL_IP=10.130.125.41

    cfssl gencert \
        -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=ca-config.json \
        -hostname=kube-worker-0,${EXTERNAL_IP},${INTERNAL_IP} \
        -profile=kubernetes \
        worker0-csr.json | cfssljson -bare worker0
        
        
will produce the following:
    
    worker0.pem
    worker0-key.pem

# Generate the Controller manager certificates

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

Will generate the following:

    kube-controller-manager.pem
    kube-controller-manager-key.pem
    

# Generate the Kube proxy certificates

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-proxy-csr.json | cfssljson -bare kube-proxy

will generate the following:
    
    kube-proxy.pem
    kube-proxy-key.pem

# Generate Kube-scheduler client certificate

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-scheduler-csr.json | cfssljson -bare kube-scheduler                                  

Will generate the files:
 
    kube-scheduler.pem
    kube-scheduler-key.pem
    

# Generate API Server certificates

Add all internal IPs of the worker and master nodes including the public ip addresses into the `-hostname` field
Must add the Service IP of the api-server into the hostname list too.
`10.32.0.1` - is the kubernetes svc IP address. (i.e. kubernetes.default, kubernetes)

    export KUBERNETES_PUBLIC_ADDRESS=178.128.126.32,159.65.133.180
    

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=10.32.0.1,10.130.125.41,10.130.123.184,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
      -profile=kubernetes \
      kubernetes-csr.json | cfssljson -bare kubernetes       

Will generate the following files:

    kubernetes.pem
    kubernetes-key.pem
    
# Generate service account certificates
The Kubernetes Controller Manager leverages a key pair to generate and sign service account tokens as describe in the managing service accounts documentation.



    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      service-account-csr.json | cfssljson -bare service-account
      
Will generate the following files:
    
    service-account-key.pem
    service-account.pem
    
    
# distribute the keys to the servers.

Master

    scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
        service-account-key.pem service-account.pem root@159.65.133.180:~/    
        
Worker

    scp ca.pem worker0.pem worker0-key.pem root@178.128.126.32:~/    




##  Kubelet Kubernetes Configuration File

     kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=./pki/ca.pem \
        --embed-certs=true \
        --server=https://159.65.133.180:6443 \
        --kubeconfig=worker0.kubeconfig
    
      kubectl config set-credentials system:node:worker0 \
        --client-certificate=./pki/worker0.pem \
        --client-key=./pki/worker0-key.pem \
        --embed-certs=true \
        --kubeconfig=worker0.kubeconfig
    
      kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:node:worker0 \
        --kubeconfig=worker0.kubeconfig
    
      kubectl config use-context default --kubeconfig=worker0.kubeconfig   
      
  
## Kube proxy Kubernetes configuration file


     kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=./pki/ca.pem \
        --embed-certs=true \
        --server=https://159.65.133.180:6443 \
        --kubeconfig=kube-proxy.kubeconfig
    
      kubectl config set-credentials system:kube-proxy \
        --client-certificate=./pki/kube-proxy.pem \
        --client-key=./pki/kube-proxy-key.pem \
        --embed-certs=true \
        --kubeconfig=kube-proxy.kubeconfig
    
      kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-proxy \
        --kubeconfig=kube-proxy.kubeconfig
    
      kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig   
      
## Kube controller kubernetes configuration file

    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=./pki/ca.pem \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=kube-controller-manager.kubeconfig
    
      kubectl config set-credentials system:kube-controller-manager \
        --client-certificate=./pki/kube-controller-manager.pem \
        --client-key=./pki/kube-controller-manager-key.pem \
        --embed-certs=true \
        --kubeconfig=kube-controller-manager.kubeconfig
    
      kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-controller-manager \
        --kubeconfig=kube-controller-manager.kubeconfig
    
      kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
      
      
## Kube scheduler kubernetes configuration file

     kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=./pki/ca.pem \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=kube-scheduler.kubeconfig
    
      kubectl config set-credentials system:kube-scheduler \
        --client-certificate=./pki/kube-scheduler.pem \
        --client-key=./pki/kube-scheduler-key.pem \
        --embed-certs=true \
        --kubeconfig=kube-scheduler.kubeconfig
    
      kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-scheduler \
        --kubeconfig=kube-scheduler.kubeconfig
    
      kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig  
      
      
## Admin kubernetes configuration file

    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=./pki/ca.pem \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=admin.kubeconfig
    
      kubectl config set-credentials admin \
        --client-certificate=./pki/admin.pem \
        --client-key=./pki/admin-key.pem \
        --embed-certs=true \
        --kubeconfig=admin.kubeconfig
    
      kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=admin \
        --kubeconfig=admin.kubeconfig
    
      kubectl config use-context default --kubeconfig=admin.kubeconfig       
      
      
## distribute the kubernetes configuration files

Worker


    scp worker0.kubeconfig kube-proxy.kubeconfig root@178.128.126.32:~/
    
    
Master

    scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig root@159.65.133.180:~/
                       
                       
                       
## Bootstrap etcd cluster.
                       
controller machine internal IP `10.130.123.184`

    cat <<EOF | sudo tee /etc/systemd/system/etcd.service
    [Unit]
    Description=etcd
    Documentation=https://github.com/coreos
    
    [Service]
    ExecStart=/usr/local/bin/etcd \
      --name ${ETCD_NAME} \
      --cert-file=/etc/etcd/kubernetes.pem \
      --key-file=/etc/etcd/kubernetes-key.pem \
      --peer-cert-file=/etc/etcd/kubernetes.pem \
      --peer-key-file=/etc/etcd/kubernetes-key.pem \
      --trusted-ca-file=/etc/etcd/ca.pem \
      --peer-trusted-ca-file=/etc/etcd/ca.pem \
      --peer-client-cert-auth \
      --client-cert-auth \
      --initial-advertise-peer-urls https://10.130.123.184:2380 \
      --listen-peer-urls https://10.130.123.184:2380 \
      --listen-client-urls https://10.130.123.184:2379,https://127.0.0.1:2379 \
      --advertise-client-urls https://10.130.123.184:2379 \
      --data-dir=/var/lib/etcd
    Restart=on-failure
    RestartSec=5
    
    [Install]
    WantedBy=multi-user.target
    EOF


## Bootstrap api server

cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=10.130.123.184 \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.130.123.184:2379 \\
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


--allocate-node-cidrs=true
--cluster-cidr=10.244.0.0/16


cat <<EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --allocate-node-cidrs=true \\
  --cluster-cidr=10.244.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF




cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: componentconfig/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF


cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF




export POD_CIDR=10.244.0.0/16

cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF




sudo mv worker0-key.pem worker0.pem /var/lib/kubelet/
  sudo mv worker0.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/


cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/worker0.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/worker0-key.pem"
EOF


cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF



cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF




## Create client kubernetes configuration

kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=./pki/ca.pem \
    --embed-certs=true \
    --server=https://159.65.133.180:6443 \
    --kubeconfig=client-admin.conf

  kubectl config set-credentials admin \
    --client-certificate=./pki/admin.pem \
    --client-key=./pki/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=client-admin.conf

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=client-admin.conf

  kubectl config use-context kubernetes-the-hard-way --kubeconfig=client-admin.conf                       
  
  
  
  ### Install coredns
  
  `kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml`
  
  
  