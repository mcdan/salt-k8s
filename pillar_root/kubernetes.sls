kubernetes:
  cluster-name: vagrant-k8s
  cert-root: /opt/k8s/certs
  conf-root: /opt/k8s/conf
  controller-ip: 10.0.0.10
  binary-root: /opt/bin/kubernetes
  cluster-cidr: 10.200.0.0/16
  pod-cidr-prefix: 10.200.
  pod-cidr-suffix: .0/24