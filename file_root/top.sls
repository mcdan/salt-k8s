base:
  'G@roles:worker':
    - common
    - kubelet
  'G@roles:controller':
    - common
    - kube-controller
    # - cilium