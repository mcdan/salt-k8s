controller-ca-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/ca.pem
    - source: salt://certs/ca.pem
    - makedirs: True

controller-ca-key-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/ca-key.pem
    - source: salt://certs/ca-key.pem
    - makedirs: True

kubernetes-key:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/kubernetes-key.pem
    - source: salt://certs/kubernetes-key.pem
    - makedirs: True

kubernetes-pem:
  file.managed:
    - name: {{ pillar['kubernetes']['cert-root'] }}/kubernetes.pem
    - source: salt://certs/kubernetes.pem
    - makedirs: True

kubernetes-encryption-config:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/encryption-config.yaml
    - source: salt://kube-controller/encryption-config.template.yaml
    - template: jinja
    - makedirs: True
    - unless: test -f {{ pillar['kubernetes']['conf-root'] }}/encryption-config.yaml    
    - context:
      ENCRYPTION_KEY: {{salt['random.str_encode'](salt['random.get_str'](32), 'base64')}}