# Class to configure the changealert email report processor.
#
# This class will configure the details for the
# changealert report processor
#
# @summary Configure the changealert email report processor.
#
# @example Declaring the class
#   include changealert
#
# @param from_address The e-mail adress that should be visible in the from-adress field.
# @param to_address The receipient e-mail adresses as comma separated list.
# @param smtp_server The hostname or ip address of the SMTP Mail server the e-mail should be send to.
# @param smtp_domain The domain name the e-mail should be delivered at.
# @param smtp_port The Port number the smpt server should be reachable at.
# @param hostnameparts An array of strings which is matched against each hostname with .include?
#                      if the string is found in the hostname, the report will be send. Otherwise
#                      no report is send.
# @param ensure can be 'present' or 'absent' to either configure the report processor and activate
#               it, or to remove it
class changealert (
  String $from_address,
  String $to_address,
  String $smtp_server,
  String $smtp_domain,
  Integer $smtp_port,
  Array $hostnameparts,
  Enum['present', 'absent'] $ensure = 'present',
  ) {

  file {"${settings::confdir}/changealert.yaml":
    ensure  => $ensure,
    owner   => $settings::user,
    group   => $settings::group,
    mode    => '0644',
    content => template('changealert/changealert.erb'),
  }
  -> ini_subsetting { 'reports_changealert':
    ensure               => $ensure,
    path                 => "${::settings::confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'changealert',
    subsetting_separator => ',',
    notify               => Service['pe-puppetserver'],
  }
}
