
require 'puppet'
require 'yaml'


begin
  require 'mail'
rescue LoadError => e
  Puppet.info 'This report requires the mail gem to run'
end

Puppet::Reports.register_report(:changealert) do

  def process

    configfile = File.join([File.dirname(Puppet.settings[:config]), 'changealert.yaml'])
    raise(Puppet::ParseError, "auditlert configfile not readable") unless File.exist?(configfile)
    config = YAML.load_file(configfile)

    if checkreporthost(config['hostnameparts'], self.host)
      if self.status == 'changed'
        subject = "Puppet Host #{self.host} Change alert"
        output = getchangedressources(self.resource_statuses)
        sendmail(config, subject, output.join("\n"))
      end
      if self.status == 'failed'
        subject = "Puppet Host #{self.host} Puppet run failed"
        output = getfailedressources(self.resource_statuses)
        sendmail(config, subject, output.join("\n"))
      end
      if self.status != 'failed' and self.cached_catalog_status == 'on_failure'
        subject = "Puppet Host #{self.host} run failed with cached catalog"
        sendmail(config, subject, self.time)
      end
    end
  end

  def sendmail(config, subject, body)
    Mail.defaults do
      delivery_method :smtp,
                      address: config['smtp_server'],
                      port: config['smtp_port'],
                      domain: config['smtp_domain']
    end
    Mail.deliver do
      to config['to_address']
      from config['from_address']
      subject subject
      body body
    end
  end

  def checkreporthost(hostnameparts, hostname)
    result = false
    hostnameparts.each do |part|
      if hostname.include? part
        result = true
      end
    end
    result
  end

  def getchangedressources(ressources)
    output = []
    output << "The following ressources changed:\n"
    ressources.each do |theresource, resource_status|
      if resource_status.change_count > 0
        output << "\nResource: #{resource_status.title}"
        output << "Type: #{resource_status.resource_type}"
        resource_status.events.each do |event|
          output << "Property: #{event.property}"
          output << "Value: #{event.desired_value}"
          output << "Status: #{event.status}"
          output << "Time: #{event.time}"
        end
      end
    end
    output
  end

  def getfailedressources(ressources)
    output = []
    output << "The following ressources failed:\n"
    ressources.each do |theresource, resource_status|
      if resource_status.failed == true
        output << "\nResource: #{resource_status.title}"
        output << "Type: #{resource_status.resource_type}"
        resource_status.events.each do |event|
          if event.status == 'failure'
            output << "Message: #{event.message}"
            output << "Time: #{event.time}"
          end
        end
      end
    end
    output
  end
end
