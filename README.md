# Description
* scripts to install Eclipse Neon with PyDev or PyCharm 2016.2.3 on Ubuntu 16.04 LTS with Unity Desktop
* installs all requirements for odoo development, including PostgreSQL
* install git client: apt-get install git
* get repository: git clone https://github.com/pragmasoft-de/odoo-dev-tools
* go into directory: cd odoo-dev-tools
* make scripts executable: chmod +x *.sh
* the scripts must be run as root
* for Eclipse: run the script ./install_eclipse_neon_with_pydev.sh username
* for PyCharm: run the script ./install_pycharm_community.sh username
* 
* get odoo from the repository, e.g. git clone https://github.com/odoo/odoo --depth 1 -b 10.0 for getting odoo 10
* go into the odoo directory and run pip install -r requirements.txt
* 
* start developing ;-)
