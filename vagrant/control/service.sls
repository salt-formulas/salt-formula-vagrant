{%- from "vagrant/map.jinja" import control with context %}
{%- if control.enabled %}

vagrant_download_package:
  cmd.run:
  - name: wget {{ control.base_url }}/{{ control.base_file }}
  - unless: "[ -f {{ control.root_dir }}/{{ control.base_file }} ]"
  - cwd: {{ control.root_dir }}

vagrant_package:
  pkg.installed:
  - sources:
    - vagrant: {{ control.root_dir }}/{{ control.base_file }}
  - require:
    - cmd: vagrant_download_package
  - require_in:
    - file: {{ control.base_dir }}

{{ control.base_dir }}:
  file.directory:
  - makedirs: true

{%- endif %}