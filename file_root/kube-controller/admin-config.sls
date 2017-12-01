admin-cert:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/admin.pem
    - source: salt://certs/admin.pem
    - makedirs: True

admin-key:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/admin-key.pem
    - source: salt://certs/admin-key.pem
    - makedirs: True


admin-config-set-cluster:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-cluster {{ pillar['kubernetes']['cluster-name'] }} --certificate-authority={{ pillar['kubernetes']['cert-root'] }}/ca.pem --embed-certs=true --server=https://{{ pillar['kubernetes']['public-ip'] }}:6443 --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
    - unless: grep "{{ pillar['kubernetes']['cluster-name'] }}" {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig

admin-config-set-credentials:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-credentials admin --client-certificate={{ pillar['kubernetes']['cert-root'] }}/admin.pem --client-key={{ pillar['kubernetes']['cert-root'] }}/admin-key.pem --embed-certs=true --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
    - unless: grep "admin" {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig

admin-config-set-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config set-context default --cluster={{ pillar['kubernetes']['cluster-name'] }} --user=admin --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
    - unless: 'grep "name: default" {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig'

admin-config-use-context:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl config use-context default --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
    - unless: 'grep "current-context: default" {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig'

admin-allow-ubuntu:
  cmd.run:
    - name: chown ubuntu {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
    - unless: sudo -u ubuntu head -n 1 {{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig
