# odoo-clouder

Odoo 9 with Clouder 0.9.0 modules


# DOCKER REPO
https://hub.docker.com/r/pasgou/odoo-clouder/

# Volumes for addons :
* "/opt/odoo/addons/CE_inherited" : adapted modules from Odoo official Community version,
* "/opt/odoo/addons/enterprise" : volume where install Enterprise modules,
* "/opt/odoo/addons/ENT_inherit" : if modules from Enterprise version are used in new or inherited modules,
* "/opt/odoo/addons/external" : Community modules (OCA or others),
* "/opt/odoo/addons/nonfree" : non free modules (paid themes for example), and your own modules wich depend from nonfree module(s)
* "/opt/odoo/addons/private" : your own modules from scratch, even if they depend from other (community) modules

You can use them with -v argument

# Environment Variables :

Tweak these environment variables to easily connect to a postgres server:

* HOST: The address of the postgres server. If you used a postgres container, set to the name of the container. Defaults to db.
* PORT: The port the postgres server is listening to. Defaults to 5432.
* USER: The postgres role with which Odoo will connect. If you used a postgres container, set to the same value as  POSTGRES_USER. Defaults to odoo.
* PASSWORD: The password of the postgres role with which Odoo will connect. If you used a postgres container, set to the same value as POSTGRES_PASSWORD. Defaults to odoo.