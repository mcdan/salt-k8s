kubelet-ca-pem:
  file.managed:
    - name: /opt/k8s/certs/ca.pem
    - source: salt://certs/ca.pem
    - makedirs: True

kubelet-node-key:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem
    - source: salt://certs/{{ grains['nodename'] }}-key.pem
    - makedirs: True

kubelet-node-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}.pem
    - source: salt://certs/{{ grains['nodename'] }}.pem
    - makedirs: True

kubelet-config-set-cluster:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-cluster {{ pillar['kubernetes']['cluster-name'] }} --certificate-authority={{ pillar['kubernetes']['cert-root'] }}/ca.pem --embed-certs=true --server=https://{{ pillar['kubernetes']['controller-ip'] }}:6443 --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig
    - unless: grep "{{ pillar['kubernetes']['cluster-name'] }}" {{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig

kubelet-config-set-credentials:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-credentials system:node:{{ grains['nodename'] }}.local --client-certificate={{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}.pem --client-key={{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem --embed-certs=true --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig
    - unless: grep "system:node:{{ grains['nodename'] }}.local" {{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig

kubelet-config-set-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-context default --cluster={{ pillar['kubernetes']['cluster-name'] }} --user=system:node:{{ grains['nodename'] }}.local --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig
    - unless: 'grep "name: default" {{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig'

kubelet-config-use-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config use-context default --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig
    - unless: 'grep "current-context: default" {{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig'

kubelet-cni:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz
    - source_hash: sha256=f04339a21b8edf76d415e7f17b620e63b8f37a76b2f706671587ab6464411f2d
    - unless: test -f /opt/cni/bin/loopback

loopback-network:
  file.managed:
    - name: /etc/cni/net.d/99-loopback.conf
    - source:  salt://kubelet/loopback-network.conf
    - makedirs: True

kubelet-service-conf:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source:  salt://kubelet/kubelet.service.template
    - template: jinja
    - context:
      CERT_FILE: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}.pem
      CERT_KEY: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem
      CA_CERT_FILE: {{ pillar['kubernetes']['cert-root'] }}/ca.pem
      POD_CIDR: {{ pillar['kubernetes']['pod-cidr-prefix'] }}10{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['pod-cidr-suffix'] }}
      K8S_BIN_ROOT: {{ pillar['kubernetes']['binary-root'] }} 
      KUBE_CONFIG: {{ pillar['kubernetes']['conf-root'] }}/node.kubeconfig
      CLUSTER_DNS: {{ pillar['kubernetes']['dns-ip'] }}
      HOSTNAME: {{ grains['nodename'] }}.local
      CLUSTER_CIDR: {{ pillar['kubernetes']['cluster-cidr'] }}

kubelet-service:
  service.running:
    - name: kubelet.service
    - enable: True

kubelet-restart:
  cmd.run:
    - name: systemctl restart kubelet.service
    - onchanges:
      - file: kubelet-service-conf
