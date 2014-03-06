
{% set os = salt['grains.item']('os')['os'] %}

{% set os_family = salt['grains.item']('os_family')['os_family'] %}

{% set cpu_arch = salt['grains.item']('cpuarch')['cpuarch'] %}

{% set kernel = salt['grains.item']('kernel')['kernel'] %}

{% if pillar.vagrant.controller.version is defined %}
{% set vagrant_version = pillar.vagrant.controller.version %}
{% else %}
{% set vagrant_version = '1.4.3' %}
{% endif %}

{% set vagrant_base_url = 'https://dl.bintray.com/mitchellh/vagrant' %}
{% set vagrant_base_file = 'vagrant_' + vagrant_version + '_x86_64.deb' %}

{%- if pillar.vagrant.controller.enabled %}

{%- if kernel == "Linux" %}

vagrant_download_package:
  cmd.run:
  - name: wget {{ vagrant_base_url }}/{{ vagrant_base_file }}
  - unless: "[ -f /root/{{ vagrant_base_file }} ]"
  - cwd: /root

vagrant_package:
  pkg.installed:
  - sources:
    - vagrant: /root/{{ vagrant_base_file }}
  - require:
    - cmd: vagrant_download_package

/srv/vagrant:
  file:
  - directory
  - makedirs: true
  - require:
    - pkg: vagrant_package

{%- for plugin in pillar.vagrant.controller.plugins %}

{% if plugin.name == 'vagrant-salt' %}
vagrant_install_plugin_{{ plugin.name }}:
  cmd.run:
  - name: "vagrant plugin install {{ plugin.name }}"
  - unless: "[ -d /root/.vagrant.d/gems/gems/vagrant-salt-0.4.0 ]"
{% endif %}

{%- if plugin.name == 'vagrant-windows' %}

vagrant_plugin_{{ plugin.name }}_packages:
  pkg.installed:
  - names:
    - ruby-rvm

vagrant_plugin_{{ plugin.name }}_rvm_install:
  cmd.run:
  - name: rvm install ruby 2.0.0
  - require:
    - pkg: vagrant_plugin_{{ plugin.name }}_packages

vagrant_install_plugin_{{ plugin.name }}:
  cmd.run:
  - name: "vagrant plugin install {{ plugin.name }}"
  - unless: "[ -d /root/.vagrant.d/gems/gems/vagrant-windows-1.2.3 ]"
  - require:
    - cmd: vagrant_plugin_{{ plugin.name }}_rvm_install

{%- endif %}

{%- endfor %}

{%- for image in pillar.vagrant.controller.images %}
vagrant_install_image_{{ image.name }}:
  cmd.run:
  - name: "vagrant box add {{ image.name }} {{ image.url }}"
  - unless: "[ -d /root/.vagrant.d/boxes/{{ image.name }} ]"
{%- endfor %}

{%- for system in pillar.vagrant.controller.systems %}

/srv/vagrant/{{ system.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant

/srv/vagrant/{{ system.name }}/Vagrantfile:
  file:
  - managed
  - source: salt://vagrant/conf/Vagrantfile
  - template: jinja
  - defaults:
    system_name: "{{ system.name }}"

/srv/vagrant/{{ system.name }}/salt/minion_keys:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}

{%- for server in system.servers %}

{%- if server.sync_folders is defined %}
{%- for folder in server.sync_folders %}
/srv/vagrant/{{ system.name }}/{{ folder.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}
{%- endfor %}
{%- endif %}

{%- if server.master is defined %}

/srv/vagrant/{{ system.name }}/salt/{{ server.name }}:
  file:
  - directory
  - makedirs: true
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

/srv/vagrant/{{ system.name }}/salt/{{ server.name }}/minion.conf:
  file:
  - managed
  - source: salt://vagrant/conf/minion.conf
  - template: jinja
  - defaults:
    server_name: "{{ server.hostname }}"
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/{{ server.name }}

{% if pillar.salt is defined %}
{% if pillar.salt.master is defined %}

cp /srv/salt/minion_keys/{{ server.hostname }}.pub /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub:
  cmd.run:
  - unless: "[ -f /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub ]"
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

cp /srv/salt/minion_keys/{{ server.hostname }}.pem /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - unless: "[ -f /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem ]"
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

chmod 644 /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - require:
    - cmd: cp /srv/salt/minion_keys/{{ server.hostname }}.pem /srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem

{% else %}

/srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pub
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

/srv/vagrant/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  file:
  - managed
  - source: salt://minion_keys/{{ server.hostname }}.pem
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/minion_keys

{%- endif %}
{%- endif %}

{%- endif %}

{% if server.status == "active" %}
start_vagrant_box_{{ server.hostname }}:
  cmd.run:
  - name: vagrant up {{ server.name }}
  - cwd: /srv/vagrant/{{ system.name }}
  - require:
    - file: /srv/vagrant/{{ system.name }}/salt/{{ server.name }}/minion.conf
{%- endif %}

{%- set scripts = pillar.get("vagrant",{}).get("controller", {}).get("scripts", false) %}

{%- if scripts == true %}

/srv/vagrant/scripts/{{ server.name }}.sh:
  file.managed:
  - source: salt://vagrant/conf/run.sh
  - template: jinja
  - makedirs: true
  - defaults:
    server_name: {{ server.name }}
    system_name: {{ system.name }}
  - user: root
  - group: root
  - mode: 770

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}

{%- endif %}
