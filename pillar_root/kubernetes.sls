#ETCDCTL_API=3 ./etcdctl --cacert=/opt/k8s/certs/ca.pem --endpoints=https://10.0.0.10:2379 --cert=/opt/k8s/certs/kubernetes.pem --key=/opt/k8s/certs/kubernetes-key.pem  member list 
kubernetes:
  cluster-name: vagrant-k8s
  cert-root: /opt/k8s/certs
  conf-root: /opt/k8s/conf
  controller-ip: 10.0.0.10
  binary-root: /opt/bin/kubernetes
  cluster-cidr: 10.200.0.0/16
  pod-cidr-prefix: 10.200.
  pod-cidr-suffix: .1/25
  bridge-cidr-prefix: 10.200.
  bridge-cidr-suffix: .1/24