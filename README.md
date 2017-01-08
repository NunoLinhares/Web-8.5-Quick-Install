# Web-8.5-Quick-Install

This is my first attempt to create an "all-in-one" installer for people that don't want to be bothered following setup instructions from docs.sdl.com

# Pre-Requisites

To use this script, you need:

* SDL Web 8.5 installer and valid licenses
* Windows 2012 or higher 
* MSSQL (any of the versions supported by SDL Web)
* Note if IIS is already installed, stop and delete the default website before running this script.  If IIS is not installed, the script will install IIS and take care of the default website too.

# Instructions

Edit the file "Quick-Install-Options.ps1" and modify it to fit your needs. At a minimum, you need to specify valid locations for the installer and licenses. The rest of the defaults should be good enough.

Run the Web-8.5-Quick-Install.ps1 script (as Administrator) to launch the CM installation process. At the end of the CM Installer your machine will reboot without warning.
Once the machine is rebooted, run the script again and it will continue.

# What do you get?

This will:
* Create SDL Web 8.5 databases
* Install SDL Web Content Manager
* Install and configure SDL Web 8.5 Microservices (Discovery, Deployer, Session-Enabled Content Service, Preview Service)
* Install the DXA (CM and CD)

At the end of the script you get:
* CM running on port 80
* Staging site on port 82


# Bugs
I still want to make it more robust and configurable (especially for distributed environments) and iron out some quirks.

# Acknowledgements

Thanks Peter Kjaer for the excellent Tridion Powershell Modules (https://github.com/pkjaer/tridion-powershell-modules)

# Apologies

This is my first ever Powershell script... so, yes, it's probably full of odd stuff for those of you that have been going at it for a while. Nope, I'm not embarrassed, just focused on the results
