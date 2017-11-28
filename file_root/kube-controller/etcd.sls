etcd-binary:
  archive.extracted:
    - name: /opt/bin/etcd
    - source: https://github.com/coreos/etcd/releases/download/v3.2.8/etcd-v3.2.8-linux-amd64.tar.gz
    - source_hash: sha256=3b317ab2367ea3fde4739edcc8f628937015f7bf1704712e62b490260ea065f1
    - enforce_toplevel: False
    - options: --strip-components=1
    - if_missing: /opt/bin/etcd/etcd
    - unless: test -f /opt/bin/etcd/etcd

etcd-data-directory:
  file.directory:
    - name: /var/lib/etcd
    - makedirs: True

etcd-service-conf:
  file.managed:
    - name: /etc/systemd/system/etcd.service
    - source: salt://kube-controller/etcd.service.template
    - template: jinja
    - context:
        certroot: {{ pillar['kubernetes']['cert-root'] }}
        nodename: {{ grains['nodename'] }}
        internalIP: {{ pillar['kubernetes']['controller-ip']}}

etcd-service:
  service.running:
    - name: etcd.service
    - enable: True
    - watch:
      - file: etcd-service-conf