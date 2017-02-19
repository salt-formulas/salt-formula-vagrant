
===============
Vagrant formula
===============

Vagrant provides easy to configure, reproducible, and portable work
environments built on top of industry-standard technology and controlled by a
single consistent workflow to help maximize the productivity and flexibility
of you and your team.

To achieve its magic, Vagrant stands on the shoulders of giants. Machines are
provisioned on top of VirtualBox, VMware, AWS, or any other provider. Then,
industry-standard provisioning tools such as shell scripts, Chef, or Puppet,
can be used to automatically install and configure software on the machine.


Sample pillars
==============

Vagrant with VirtualBox cluster

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        cluster:
          clustername:
            provider: virtualbox
            domain: local.domain.com
            control:
              engine: salt
              host: salt.domain.com
            node:
              box1:
                status: suspended
                image: ubuntu1204
                memory: 512
                cpus: 1
                networks:
                - type: hostonly
                  address: 10.10.10.110

Vagrant with Windows plugin

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        plugin:
          vagrant-windows:
            version: 1.2.3

Vagrant with presseded images

.. code-block:: yaml

    vagrant:
      control:
        enabled: true
        image:
          ubuntu1204:
            source: http://files.vagrantup.com/precise64.box


Sample usage
============

Start and connect machine

.. code-block:: bash

    cd /srv/vagrant/<cluster_name>
    vagrant up <node_name>
    vagrant ssh <node_name>


External links
==============

* http://www.vagrantup.com/
* http://docs.vagrantup.com/v2/
* http://docs.vagrantup.com/v2/synced-folders/


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-vagrant/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-vagrant

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
