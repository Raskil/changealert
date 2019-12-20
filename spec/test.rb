require 'yaml'
require 'pp'

configfile = './changealert.yaml'
raise(Puppet::ParseError, "auditlert configfile not readable") unless File.exist?(configfile)
config = YAML.load_file(configfile)

pp config
