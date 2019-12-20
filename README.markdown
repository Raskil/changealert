# changealert

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with changealert](#setup)
    * [What changealert affects](#what-changealert-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with changealert](#beginning-with-changealert)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The Module delivers and configures a custom report Processor that is able to deliver e-Mail about Puppet agent runs that did changes or failed.
It has been tested with Puppet Enterprise 2017.2.4 till 2019.2.0 but should work with older and newer releases as well. If yxou use Open source,
you need to make sure that the ini_setting is handled correctly that is declared in this modules init.pp and does not collide with something else.

The report processor sends reports based on the hostname of the agent generating the report and the module parameter hostnameparts.
The basic logic is the following:
The report processor takes every string inside of hostnameparts array and sees if that string is included in the hostname of the report.
If not, there is no report send.
If yes, then a report is send if the following conditions are met:
* The puppet run generating the report has changed any resources on the system. A list of changed resources and properties is attached to the mail.
* The puppet run generating the report has failed on the system. A list of failed resources is attached to the mail if possible.
* The puppet run had a failed catalog compilation, but was running ok on a cached catalog.

## Setup

### What changealert affects
The following ressources are affacted:
* Custom Report Processor. This module comes with the changealrt custom report processor.
* Reports setting in master section of puppet.conf. The module inserts its own report processor into the reports ini setting in puppet.conf. This is done via the ini_subsetting module of pe. So it will happliy coexist with other subsettings/report processor.
* pe-puppetmaster service. If the above reports ini setting is changed, the pe-puppetmaster deamon is restarted.
* The file changealert.yaml in puppets confdir is created and managed. This file is used to customize the report processor.

**Waring**
Report Processors are not environment safe. So don't install the module into your environments. See [Setup](#setup) section for more details.


### Setup Requirements 

For this module to work, your pe-puppetserver needs the ruby mail gem installed. Install it via this command:
```bash
puppetserver gem install mail
```

### Beginning with changealert	
**Waring**
Report Processors are not environment safe. So don't install the module into your environments. Don't use means like code-manager or r10k to deploy the module.
If you do not adhere to this, you'll get strange results.

To get the module up and running, you need to install the module on your master somewhere in the $modulepath.
You can view your modulepath like this:
```bash
puppet config print modulepath
#/etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/environments/production/site:/etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules
```

Usually "/opt/puppetlabs/puppet/modules" is a pretty good location for a globally active module that can only be installed once. So here is what you need to do on your master:
```bash
# Setup root to use the same ssh key to connect to Bitbucket as user pe-puppet does.
echo -e "Host foo.bar.com \n  IdentityFile /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa" >> ~/.ssh/config
chmod 600 ~/.ssh/config
# Clone the module and restart puppetserver
cd /opt/puppetlabs/puppet/modules 
git clone ssh://git@github.com:Raskil/changealert.git
systemctl restart pe-puppetserver
```

This should install the module for you.

## Usage
There are several methods to use this module. I found it easiest to be used via the Puppet console.

### Using it via Puppet Console
Open your Puppet console and navigate to Nodes->Classification. Find the group "PE Infrastructure"->"PE Master" and click on it.
Click on the pane "Classes". In the text box "Add new class" type changealert and click on the button "add class".

Now find the class changealert in the list of classes and configure every parameter that it has. They are all mandatory! See puppet-strings documentation in the docs folder for details about the parameters.
Here are some examples:

```text
from_address  = "puppetmaster@example.com"
hostnameparts = ["pro", "foobarsystem.example.com"]
smtp_domain   = "example.com"
smtp_port     = 25
smtp_server   = "172.17.8.10"
to_address    = "yourname@example.com, youtechmail@example.com"
```

### Using it via Hiera, Puppetcode, etc.
You could alternatively set the parameter via Hiera as well. Just set them like every other class parameter. But please
bear in mind that console parameters have precedence over parameters from hiera. So it is wise to configure them in one location only.

If you dont apply the class to your Pupept Master via the Console, then you need to apply it via different means. All you need to do is include/contain the changealert class and set every parameter that it has.
Please make sure that this Class is only applied on your Puppet master.

### Updating the Module
To get to the latest release, do the following on your master:
```bash
cd /opt/puppetlabs/puppet/modules/changealert
git pull
systemctl restart pe-puppetserver
```

## Reference

See puppet-strings documentation in docs folder.

## Limitations

As already pointed out, report processor are not environment safe. Keep that in mind.
