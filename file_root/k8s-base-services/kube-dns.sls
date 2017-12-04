#kube-dns:
#  kubernetes.deployment_present:
#    - name: kube-dns
#    - source: salt://k8s-base-services/kube-dns.yaml.template
#    - template: jinja
#    - context:
#      CLUSTER_DNS: {{ pillar['kubernetes']['dns-ip'] }}

kube-dns-deployment-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/kube-dns.yaml
    - source: salt://k8s-base-services/kube-dns.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      CLUSTER_DNS: {{ pillar['kubernetes']['dns-ip'] }}

kube-dns-deployment:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig create -f {{ pillar['kubernetes']['conf-root'] }}/deploys/kube-dns.yaml
    - unless: kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig -n kube-system get deployments kube-dns
