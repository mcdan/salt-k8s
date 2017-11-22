{% if 'worker' in grains['roles' ]%}
docker-default-iptables:
  iptables.flush:
    - table: nat
down-docker-default:
  network.managed:
    - name: docker0
    - enabled: False
    - type: bridge
    - ports: 
remove-docker-interface:
   cmd.run:
     - name: ip link delete docker0
     - onlyif: ifconfig docker0

cbr0-create:
  cmd.run:
    - name:  ip link add name cbr0 type bridge
    - unless: ifconfig cbr0
cbr0-mtu:
  cmd.run:
    - name: ip link set dev cbr0 mtu 1460
    - onchanges:
      - cmd: cbr0-create
cbr0-addr:
  cmd.run:
    - name: ip addr add {{ pillar['kubernetes']['bridge-cidr-prefix'] }}{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['bridge-cidr-suffix'] }} dev cbr0
    - onchanges:
      - cmd: cbr0-create
cbr0-up:
  cmd.run:
    - name: ip link set dev cbr0 up
    - onchanges:
      - cmd: cbr0-create

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
#route add -net 10.200.1.0 netmask 255.255.255.0 gw 10.0.0.11
#route add -net 10.200.2.0 netmask 255.255.255.0 gw 10.0.0.12
#route add -net 10.200.3.0 netmask 255.255.255.0 gw 10.0.0.13


#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#0.0.0.0         10.200.2.1      0.0.0.0         UG    0      0        0 eth0
#10.200.2.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0


# ip addr add 10.200.1.1/24 dev cbr0
# ip addr add 10.200.2.1/24 dev cbr0
# ip addr add 10.200.3.1/24 dev cbr0
# route add -net 10.200.0.0 netmask 255.255.0.0 gw 10.200.2.1


#iptables -t nat -A POSTROUTING ! -d 10.200.0.0/16 -m addrtype ! --dst-type LOCAL -j MASQUERADE

# 10.0.0.11 -> 10.200.1.0/24
# sudo route add -net 10.200.1.0 netmask 255.255.255.0 gw 10.0.0.11

#ClusterCIDR= 10.200.0.0/16 aaka  255.255.0.0 
#PodCIDR = 10.200.1.0/24 aka 255.255.255.0  
