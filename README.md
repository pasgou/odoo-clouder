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
