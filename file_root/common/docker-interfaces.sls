{% if 'worker' in grains['roles' ]%}
cbr0-adapter:
  network.managed:
    - name: cbr0
    - type: bridge
    - mtu: 1460
    - ipaddr: {{ pillar['kubernetes']['bridge-cidr-prefix'] }}10{{ grains['nodename'].split('-')[1] }}{{ pillar['kubernetes']['bridge-cidr-suffix'] }}
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

forward_packets:
  iptables.set_policy:
    - chain: FORWARD
    - policy: ACCEPT

net.ipv4.ip_forward:
  sysctl:
    - present
    - value: 1

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




#iptables -t nat -X DOCKER




#systemctl stop docker
#iptables -t nat -F
#iptables -t filter -F
#iptables -X DOCKER
#iptables -X DOCKER-ISOLATION
#systemctl start docker


# MIGHT WORK!
# sudo route add -net 10.200.0.0/16 dev enp0s8
# sudo route add -net 10.200.101.0/24 gw 10.200.101.1
# sudo route add -net 10.200.102.0/24 gw 10.200.102.1
# sudo route add -net 10.200.103.0/24 gw 10.200.103.1
