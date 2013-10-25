
include:
- vagrant.params
{% if pillar.vagrant.controller is defined %}
- vagrant.controller
{% endif %}
