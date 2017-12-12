gluster-storage-deployment-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/gluster-storage.yaml
    - source: salt://k8s-base-services/gluster-storage.yaml.template
    - template: jinja
    - makedirs: True
    - context:
      HEKETI_PORT: {{ pillar['kubernetes']['heketi-port'] }}

gluster-storage-sample-definition:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/deploys/nginx-gluster.yaml
    - source: salt://k8s-base-services/nginx-gluster.yaml.template
    - template: jinja
    - makedirs: True
