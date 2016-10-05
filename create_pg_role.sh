#!/bin/bash

# Script to create the database user "odoo" and set his permissions.
# The script is being called from install_odoo9.sh.
# (c) Josef Kaser 2016
# http://www.pragmasoft.de

cd /var/lib/postgresql

psql <<EOF
    create role odoo with password 'odoo';
    alter role odoo CREATEROLE;
    alter role odoo CREATEDB;
    alter role odoo CREATEUSER;
    alter role odoo LOGIN;
    \q
EOF

