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
create-docker-daemon:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://common/docker-daemon.json