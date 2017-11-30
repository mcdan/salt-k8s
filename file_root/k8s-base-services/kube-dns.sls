kube-dns-deployment:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/kube-dns.yaml
    - source: salt://k8s-base-services/kube-dns.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      CLUSTER_DNS: {{ pillar['kubernetes']['dns-ip'] }}
