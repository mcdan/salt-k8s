base:
  '*':
    - kubernetes
    {%- for root in opts['pillar_roots'][saltenv] -%}
      {%- if salt['file.file_exists']('{0}/public-ip.sls'.format(root)) %}
    - public-ip
      {% endif %}
    {%- endfor %}
    {%- for root in opts['pillar_roots'][saltenv] -%}
      {%- if salt['file.file_exists']('{0}/num-workers.sls'.format(root)) %}
    - num-workers
      {% endif %}
    {%- endfor %}
