k8s-servers:
  archive.extracted:
    - name: {{ pillar['kubernetes']['binary-root'] }}
    - source: https://dl.k8s.io/v1.8.3/kubernetes-server-linux-amd64.tar.gz
    - enforce_toplevel: False
    - options: --strip-components=1    
    - source_hash: sha256=557c231a63f5975d08565dd690381bd63d9db14528da07c7e86305a82fbd9c8b
    - unless: test -f {{ pillar['kubernetes']['binary-root'] }}/kubernetes-src.tar.gz

k8s-binary-permissions:
  cmd.run:
    - name: chmod -R a+Xr {{ pillar['kubernetes']['binary-root'] }}
