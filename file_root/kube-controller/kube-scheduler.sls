kube-scheduler-service-conf:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://kube-controller/kube-scheduler.service.template
    - template: jinja
    - context:
        certroot: {{ pillar['kubernetes']['cert-root'] }}
        nodename: {{ grains['nodename'] }}
        internalIP: {{ pillar['kubernetes']['controller-ip'] }}
        binaryroot: {{ pillar['kubernetes']['binary-root'] }}
        confroot: {{ pillar['kubernetes']['conf-root'] }}

kube-scheduler-service:
  service.running:
    - name: kube-scheduler.service
    - enable: True
    - watch:
      - file: kube-scheduler-service-conf