#!/usr/bin/python

import sys,textwrap
from jinja2 import Environment, FileSystemLoader, PackageLoader, select_autoescape

#data = open('src/scripts/destroy.sh','r').read()
#print "DEDENT: "
#print textwrap.dedent('\n     | '.join(data.splitlines()[1:]))
#destroy_sh='\n     | '.join(data.splitlines()[1:])
#print destroy_sh

env = Environment(
#  loader=PackageLoader(__name__,'/root/adop/tite-php-cartridge/src/templates/dsl'),
  loader=FileSystemLoader('src/templates/dsl'),
  autoescape=select_autoescape(['html','xml'])
)

p = {}
p['destroy_sh'] = '\n             | '.join(open('src/scripts/destroy.sh','r').read().splitlines()[1:])
p['create_sh']  = '\n             | '.join(open('src/scripts/create.sh','r').read().splitlines()[1:])

#template = env.get_template('/root/adop/tite-php-cartridge/src/templates/dsl/environment_provisioning.groovy.j2')
template = env.get_template('environment_provisioning.groovy.j2')

print template.render(**p)
