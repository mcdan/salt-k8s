added_repos:
  pkgrepo.managed:
    - humanname: Docker.io ce
    - name: deb https://download.docker.com/linux/ubuntu xenial stable
    - dist: xenial
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 0EBFCD88
    - keyserver: keyserver.ubuntu.com
    - require_in:
        - common_packages

common_packages:
  pkg.installed:
    - pkgs:
      - docker-ce
      - git