kube-apiserver-service-conf:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://kube-controller/kube-apiserver.service.template
    - template: jinja
    - context:
        certroot: {{ pillar['kubernetes']['cert-root'] }}
        nodename: {{ grains['nodename'] }}
        internalIP: {{ grains['ipv4'][0] }}
        binaryroot: {{ pillar['kubernetes']['binary-root'] }}
        confroot: {{ pillar['kubernetes']['conf-root'] }}

kube-apiserver-service::
  service.running:
    - name: kube-apiserver.service
    - enable: True
    - watch:
      - file: kube-apiserver-service-conf