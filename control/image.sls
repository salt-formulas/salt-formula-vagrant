{% from "vagrant/map.jinja" import control with context %}
{%- if control.enabled %}

{%- for name, image in control.image.iteritems() %}

vagrant_install_image_{{ name }}:
  cmd.run:
  - name: "vagrant box add {{ name }} {{ image.source }}"
  - unless: "[ -d {{ control.root_dir }}/.vagrant.d/boxes/{{ name }} ]"

{%- endfor %}

{%- endif %}