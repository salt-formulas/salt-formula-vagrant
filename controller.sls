{% from "vagrant/map.jinja" import controller with context %}

{%- if controller.enabled %}

{% if not grains.os_family in ['Macos'] %}

vagrant_download_package:
  cmd.run:
  - name: wget {{ controller.base_url }}/{{ controller.base_file }}
  - unless: "[ -f {{ controller.root_dir }}s/{{ controller.base_file }} ]"
  - cwd: {{ controller.root_dir }}

vagrant_package:
  pkg.installed:
  - sources:
    - vagrant: {{ controller.root_dir }}/{{ controller.base_file }}
  - require:
    - cmd: vagrant_download_package
  - require_in:
    - file: {{ controller.base_dir }}

{% endif %}

{{ controller.base_dir }}:
  file.directory:
  - makedirs: true

{%- for plugin in controller.plugins %}

{%- if plugin.name == 'vagrant-salt' %}

vagrant_install_plugin_{{ plugin.name }}:
  cmd.run:
  - name: "vagrant plugin install {{ plugin.name }}"
  - unless: "[ -d {{ controller.root_dir }}/.vagrant.d/gems/gems/vagrant-salt-0.4.0 ]"

{%- endif %}

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
  - unless: "[ -d {{ controller.root_dir }}/.vagrant.d/gems/gems/vagrant-windows-1.2.3 ]"
  - require:
    - cmd: vagrant_plugin_{{ plugin.name }}_rvm_install

{%- endif %}

{%- endfor %}

{%- for image in controller.images %}
vagrant_install_image_{{ image.name }}:
  cmd.run:
  - name: "vagrant box add {{ image.name }} {{ image.url }}"
  - unless: "[ -d {{ controller.root_dir }}/.vagrant.d/boxes/{{ image.name }} ]"
{%- endfor %}

{%- for system in pillar.vagrant.controller.systems %}

{{ controller.base_dir }}/{{ system.name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ controller.base_dir }}

{{ controller.base_dir }}/{{ system.name }}/Vagrantfile:
  file.managed:
  - source: salt://vagrant/conf/Vagrantfile
  - template: jinja
  - defaults:
    system_name: "{{ system.name }}"

{{ controller.base_dir }}/{{ system.name }}/salt/minion_keys:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}

{%- for server in system.servers %}

{%- if server.sync_folders is defined %}
{%- for folder in server.sync_folders %}
{{ controller.base_dir }}/{{ system.name }}/{{ folder.name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}
{%- endfor %}
{%- endif %}

{%- if server.master is defined %}

{{ controller.base_dir }}/{{ system.name }}/salt/{{ server.name }}:
  file.directory:
  - makedirs: true
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys

{{ controller.base_dir }}/{{ system.name }}/salt/{{ server.name }}/minion.conf:
  file.managed:
  - source: salt://vagrant/conf/minion.conf
  - template: jinja
  - defaults:
    server_name: "{{ server.hostname }}"
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/{{ server.name }}

{% if pillar.salt is defined %}
{% if pillar.salt.master is defined %}

cp /srv/salt/minion_keys/{{ server.hostname }}.pub {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub:
  cmd.run:
  - unless: "[ -f {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub ]"
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys

cp /srv/salt/minion_keys/{{ server.hostname }}.pem {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - unless: "[ -f {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem ]"
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys

chmod 644 {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  cmd.run:
  - require:
    - cmd: cp /srv/salt/minion_keys/{{ server.hostname }}.pem {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem

{% else %}

{{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pub:
  file.managed:
  - source: salt://minion_keys/{{ server.hostname }}.pub
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys

{{ controller.base_dir }}/{{ system.name }}/salt/minion_keys/{{ server.hostname }}.pem:
  file.managed:
  - source: salt://minion_keys/{{ server.hostname }}.pem
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/minion_keys

{%- endif %}
{%- endif %}

{%- endif %}

{% if server.status == "active" %}
start_vagrant_box_{{ server.hostname }}:
  cmd.run:
  - name: vagrant up {{ server.name }}
  - cwd: {{ controller.base_dir }}/{{ system.name }}
  - require:
    - file: {{ controller.base_dir }}/{{ system.name }}/salt/{{ server.name }}/minion.conf
{%- endif %}

{%- set scripts = pillar.get("vagrant",{}).get("controller", {}).get("scripts", false) %}

{%- if scripts == true %}

{{ controller.base_dir }}/scripts/{{ server.name }}.sh:
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
