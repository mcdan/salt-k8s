kublet-ca-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem
    - name: /opt/k8s/certs/ca.pem
    - source: salt://certs/ca.pem
    - makedirs: True

kublet-node-key:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem
    - source: salt://certs/{{ grains['nodename'] }}-key.pem
    - makedirs: True

kublet-node-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}.pem
    - source: salt://certs/{{ grains['nodename'] }}.pem
    - makedirs: True

kube-proxy-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/kube-proxy.pem
    - source: salt://certs/kube-proxy.pem
    - makedirs: True

kube-proxy-key:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/kube-proxy-key.pem
    - source: salt://certs/kube-proxy-key.pem
    - makedirs: True

kublet-set-cluster:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-cluster {{ pillar['kubernetes']['cluster-name'] }} --certificate-authority={{ pillar['kubernetes']['cert-root'] }}/ca.pem --embed-certs=true --server=https://{{ pillar['kubernetes']['controller-ip'] }}:6443 --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/{{ grains['nodename'] }}.kubeconfig

kublet-config-set-credentials:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-credentials system:node:{{ grains['nodename'] }} --client-certificate={{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}.pem --client-key={{ pillar['kubernetes']['cert-root'] }}/{{ grains['nodename'] }}-key.pem --embed-certs=true --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/{{ grains['nodename'] }}.kubeconfig

kublet-config-set-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-context default --cluster={{ pillar['kubernetes']['cluster-name'] }} --user=system:node:{{ grains['nodename'] }} --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/{{ grains['nodename'] }}.kubeconfig

kublet-config-use-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config use-context default --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/{{ grains['nodename'] }}.kubeconfig

kube-proxy-set-cluster:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-cluster {{ pillar['kubernetes']['cluster-name'] }} --certificate-authority={{ pillar['kubernetes']['cert-root'] }}/ca.pem --embed-certs=true --server=https://{{ pillar['kubernetes']['controller-ip'] }}:6443 --kubeconfig=kube-proxy.kubeconfig

kube-proxy-set-credentials:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-credentials kube-proxy --client-certificate={{ pillar['kubernetes']['cert-root'] }}/kube-proxy.pem --client-key={{ pillar['kubernetes']['cert-root'] }}/kube-proxy-key.pem --embed-certs=true --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig

kube-proxy-set-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-context default --cluster={{ pillar['kubernetes']['cluster-name'] }} --user=system:node:{{ grains['nodename'] }} --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig

kube-proxy-use-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config use-context default --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
