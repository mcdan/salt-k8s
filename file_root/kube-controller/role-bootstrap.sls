api-kublet-role-yaml:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/cluster-role.yaml
    - source: salt://kube-controller/cluster-role.yaml

add-api-kublet-role:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl apply -f {{ pillar['kubernetes']['conf-root'] }}/cluster-role.yaml
    - watch:
      - file: api-kublet-role-yaml
    - require:
      - service: kube-apiserver-service
    - unless: /opt/bin/kubernetes/server/bin/kubectl -n kube-system get clusterroles | grep "system:kube-apiserver-to-kubelet"

api-kublet-binding-yaml:
  file.managed:
    - name: {{ pillar['kubernetes']['conf-root'] }}/role-binding.yaml
    - source: salt://kube-controller/role-binding.yaml

add-kublet-role-binding:
  cmd.run:
    - name: {{ pillar['kubernetes']['binary-root'] }}/server/bin/kubectl apply -f {{ pillar['kubernetes']['conf-root'] }}/role-binding.yaml
    - watch:
      - file: api-kublet-binding-yaml
    - require:
      - service: kube-apiserver-service
    - unless: /opt/bin/kubernetes/server/bin/kubectl -n kube-system get clusterrolebinding | grep "system:kube-apiserver"
