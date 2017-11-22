{% set capath = pillar['kubernetes']['cert-root'] + '/ca.pem' %}
{% set clientkey = pillar['kubernetes']['cert-root'] + '/kubernetes-key.pem' %}
{% set clientpem = pillar['kubernetes']['cert-root'] + '/kubernetes.pem' %}

cilium-daemon-file:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/cilium.yaml
    - source: salt://cilium/cilium.yaml.template
    - template: jinja
    - context:
      CA_CERT: {{ salt['cmd.shell']('base64 -w 0 ' + capath) }}
      CONTROLLER_IP: {{ pillar['kubernetes']['controller-ip'] }}
      CLIENT_KEY: {{ salt['cmd.shell']('base64 -w 0 ' + clientkey) }}
      CLIENT_CERT: {{ salt['cmd.shell']('base64 -w 0 ' + clientpem) }}
      CONF_ROOT: {{ pillar['kubernetes']['conf-root'] }}
    - require:
       - controller-ca-pem
       - kubernetes-key
       - kubernetes-pem

cilium-create-ds:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl create -f {{ pillar['kubernetes']['conf-root'] }}/cilium.yaml
    - unless: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl get --all-namespaces=true ds | grep cilium
    - require:
      - cilium-daemon-file