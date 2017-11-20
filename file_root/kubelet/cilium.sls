mount-bpffs-service-conf:
  file.managed:
    - name: /etc/systemd/system/sys-fs-bpf.mount
    - source: salt://kubelet/sys-fs-bpf.mount

mount-bpffs-service:
  service.running:
    - name: sys-fs-bpf.mount
    - enable: True
    - watch:
      - file: mount-bpffs-service-conf

cilium-cni-network-conf:
  file.managed:
    - name: /etc/cni/net.d/10-cilium.conf
    - source: salt://kubelet/10-cilium.conf
    - makedirs: True