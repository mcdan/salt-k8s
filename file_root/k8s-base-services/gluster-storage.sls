gluster-storage-deployment-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/gluster/gluster-storage.yaml
    - source: salt://k8s-base-services/gluster-storage.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      HEKETI_PORT: {{ pillar['kubernetes']['heketi-port'] }}


gluster-k8s-deployment:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl --kubeconfig={{ pillar['kubernetes']['conf-root'] }}/admin.kubeconfig create -f {{ pillar['kubernetes']['conf-root'] }}/deploys/gluster/gluster-storage.yaml

gluster-storage-sample-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/gluster/nginx-gluster.yaml
    - source: salt://k8s-base-services/nginx-gluster.yaml.template
    - template: jinja
    - makedirs: True
