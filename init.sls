
include:
{% if pillar.vagrant.controller is defined %}
- vagrant.controller
{% endif %}
