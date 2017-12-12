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

kube-proxy-set-cluster:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-cluster {{ pillar['kubernetes']['cluster-name'] }} --certificate-authority={{ pillar['kubernetes']['cert-root'] }}/ca.pem --embed-certs=true --server=https://{{ pillar['kubernetes']['controller-ip'] }}:6443 --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
    - unless: grep "{{ pillar['kubernetes']['cluster-name'] }}" {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig

kube-proxy-set-credentials:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-credentials kube-proxy --client-certificate={{ pillar['kubernetes']['cert-root'] }}/kube-proxy.pem --client-key={{ pillar['kubernetes']['cert-root'] }}/kube-proxy-key.pem --embed-certs=true --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
    - unless: grep "kube-proxy" {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig

kube-proxy-set-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-context default --cluster={{ pillar['kubernetes']['cluster-name'] }} --user=kube-proxy --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
    - unless: 'grep "name: default" {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig'

kube-proxy-use-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config use-context default --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
    - unless: 'grep "current-context: default" {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig'

kube-proxy-config-file:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.yaml
    - source: salt://kube-shared/kube-proxy.yaml.template
    - template: jinja
    - context:
      KUBE_CONFIG: {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.kubeconfig
      CLUSTER_CIDR: {{ pillar['kubernetes']['cluster-cidr'] }}
      HOSTNAME: {{ grains['nodename'] }}.local

kube-proxy-service-conf:
  file.managed:
    - name: /etc/systemd/system/kube-proxy.service
    - source:  salt://kube-shared/kube-proxy.service.template
    - template: jinja
    - context:
      PROXY_CONFIG_FILE: {{ pillar['kubernetes']['conf-root'] }}/kube-proxy.yaml
      K8S_BIN_ROOT: {{ pillar['kubernetes']['binary-root'] }}
      CONTROLLER_IP: {{ pillar['kubernetes']['controller-ip'] }}

kube-proxy-restart:
  cmd.run:
    - name: systemctl restart kube-proxy.service
    - onchanges:
      - file: kube-proxy-service-conf

kube-proxy-service:
  service.running:
    - name: kube-proxy.service
    - enable: True
    - watch:
      - file: kube-proxy-service-conf
      - file: kube-proxy-config-file