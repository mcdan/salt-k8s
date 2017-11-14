kube-controller-manager-service-conf:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://kube-controller/kube-controller-manager.service.template
    - template: jinja
    - context:
        certroot: {{ pillar['kubernetes']['cert-root'] }}
        nodename: {{ grains['nodename'] }}
        internalIP: {{ grains['ipv4'][0] }}
        binaryroot: {{ pillar['kubernetes']['binary-root'] }}
        confroot: {{ pillar['kubernetes']['conf-root'] }}

kube-controller-manager-service:
  service.running:
    - name: kube-controller-manager.service
    - enable: True
    - watch:
      - file: kube-controller-manager-service-conf