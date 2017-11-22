dashboard-k8s-deployment:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/kubernetes-dashboard.yaml
    - source: salt://k8s-base-services/kubernetes-dashboard.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      CONTROLLER_IP: {{ pillar['kubernetes']['controller-ip'] }}
