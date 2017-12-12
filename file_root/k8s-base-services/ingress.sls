ingress-deployment-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/ingress/nginx-ingress.yaml
    - source: salt://k8s-base-services/nginx-ingress.yaml.template
    - template: jinja
    - makedirs: True
