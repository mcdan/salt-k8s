ingress-deployment-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/ingress/nginx-ingress.yaml
    - source: salt://k8s-base-services/nginx-ingress.yaml.template
    - template: jinja
    - makedirs: True

ingress-deployment:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig create -f {{ pillar['kubernetes']['conf-root'] }}/deploys/ingress/nginx-ingress.yaml
    - unless: kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig -n nginx-ingress get deployments nginx-ingress-controller

