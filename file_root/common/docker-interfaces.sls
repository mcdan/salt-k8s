#docker-default-iptables:
#  iptables.flush:
#    - table: nat
#down-docker-default:
#  network.managed:
#    - name: docker0
#    - enabled: False
#    - type: bridge
#    - ports: 
#remove-docker-interface:
#   cmd.run:
#     - name: ip link delete docker0
#     - onlyif: ifconfig docker0
{% if 'worker' in grains['roles' ]%}
configure-docker-daemon:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://common/docker-daemon.json
    - template: jinja
    - context:
      POD_CIDR: {{ pillar['kubernetes']['pod-cidr-prefix'] }}{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['pod-cidr-suffix'] }}
      BRIDGE_CIDR: {{ pillar['kubernetes']['bridge-cidr-prefix'] }}{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['bridge-cidr-suffix'] }}
docker-restart:
  cmd.run:
    - name: systemctl restart docker.service
    - onchanges:
      - file: configure-docker-daemon
{% endif %}

#route add -net 10.200.2.0 netmask 255.255.255.0 gw 10.0.0.12
#route add -net 10.200.2.0 netmask 255.255.255.0 gw 10.200.2.1
#route add -host 10.200.2.1 gw 10.0.0.12