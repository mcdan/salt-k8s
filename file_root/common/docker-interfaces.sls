forward_packets:
  iptables.set_policy:
    - chain: FORWARD
    - policy: ACCEPT

net.ipv4.ip_forward:
  sysctl:
    - present
    - value: 1

{% if 'worker' in grains['roles' ]%}
cbr0-adapter:
  network.managed:
    - name: cbr0
    - type: bridge
    - mtu: 1460
    - ipaddr: {{ pillar['kubernetes']['bridge-cidr-prefix'] }}10{{ grains['nodename'].split('-')[1] }}.1
    - netmask: 255.255.255.0
    - enabled: True
    - ports: 

down-docker-default:
  network.managed:
    - name: docker0
    - enabled: False
    - type: bridge
    - ports: 

docker-flush-filter:
  iptables.flush:
    - table: filter
    - onchanges:
      - iptables: forward_packets
      - network: down-docker-default
      
docker-flush-nat:
  iptables.flush:
    - table: nat
    - onchanges:
      - iptables: forward_packets
      - network: down-docker-default

remove-docker-interface:
   cmd.run:
     - name: ip link delete docker0
     - onlyif: ifconfig docker0

docker-no-chain:
  iptables.chain_absent:
    - name: DOCKER

docker-iso-no-chain:
  iptables.chain_absent:
    - name: DOCKER-ISOLATION

configure-docker-daemon:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://common/docker-daemon.json
    - template: jinja
    - context:
      POD_CIDR: {{ pillar['kubernetes']['pod-cidr-prefix'] }}10{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['pod-cidr-suffix'] }}
      BRIDGE_CIDR: {{ pillar['kubernetes']['bridge-cidr-prefix'] }}{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['bridge-cidr-suffix'] }}

docker-restart:
  cmd.run:
    - name: systemctl restart docker.service
    - onchanges:
      - file: configure-docker-daemon

{% endif %}