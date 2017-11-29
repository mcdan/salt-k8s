kubenet-routing-up:
  file.managed:
    - name: /etc/network/if-up.d/kubenet-routes
    - source: salt://common/kubenet-routes
    - makedirs: True
    - template: jinja
    - mode: 755
    - context:
      CMD: add

kubenet-routing-down:
  file.managed:
    - name: /etc/network/if-down.d/kubenet-routes
    - source: salt://common/kubenet-routes
    - makedirs: True
    - template: jinja
    - mode: 755
    - context:
      CMD: del

networking-restart:
  cmd.run:
    - name: systemctl restart networking.service
    - onchanges:
      - file: kubenet-routing-up