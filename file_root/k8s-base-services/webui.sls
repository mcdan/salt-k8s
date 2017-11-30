dashboard-k8s-deployment-file:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/kubernetes-dashboard.yaml
    - source: salt://k8s-base-services/kubernetes-dashboard.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      CONTROLLER_IP: {{ pillar['kubernetes']['controller-ip'] }}

dashboard-admin-role:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/dashboard-admin.yaml
    - source: salt://k8s-base-services/dashboard-admin.yaml
    - template: jinja
    - makedirs: True


dashboard-k8s-deployment:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig create -f {{ pillar['kubernetes']['conf-root'] }}/deploys/kubernetes-dashboard.yaml
    - unless: kubectl --kubeconfig --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig -n kube-system get deployments kubernetes-dashboard
