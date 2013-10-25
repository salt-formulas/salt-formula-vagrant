{%- for system in pillar.vagrant.controller.systems %}

cd "C:\vagrant\{{ system.name }}"

vagrant up

{%- endfor %}