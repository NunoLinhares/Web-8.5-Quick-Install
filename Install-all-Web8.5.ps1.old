#Requires -RunAsAdministrator

# Setup up your variables correctly.
# At a minimum, you need to point the TCM_INSTALLER_ROOT to the Root folder of the Web 8.5 installer. If your SA password is set correctly,
# Then the rest of the script should just work. 
# Obviously, feel free to customize and improve it!

# Global variables
$setupvars = @{}

$setupvars.TCM_INSTALLER_ROOT = "D:\Software\SDL Web 8\SDL Web 8.5"
$setupvars.MASTER_PASSWORD = "Tr1d10n"

$setupvars.SA_ACCOUNT = "sa"
$setupvars.SA_PASSWORD = $setupvars.MASTER_PASSWORD
$setupvars.DB_HOST = "(local)"
$setupvars.CD_LICENSE_FILE = $PSScriptRoot + "\cd_licenses.xml"
$setupvars.CM_LICENSE_FILE = $PSScriptRoot + "\license.xml"
$setupvars.SQL_SERVER_PORT = "1433"
$setupvars.CD_SERVICES_ROOT = "c:\sdl\web\"
$setupvars.DXA_DOWNLOAD_URL = "https://community.sdl.com/developers/tridion_developer/m/mediagallery/852/download"
$setupvars.DXA_STAGING_ROOT = "c:\sdl\web\dxa"



# FUNCTIONS AND SHIT
Function IsDBInstalled([string]$DBName)
{
    $result = Invoke-Sqlcmd ("SELECT [name] FROM sys.databases WHERE [name] = '$DBName'")

    return $result.ItemArray.Count -ge 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# CM Database Variables
$setupvars.CM_DB_HOST = $setupvars.DB_HOST
$setupvars.CM_DB_NAME = "Tridion_cm"
$setupvars.CM_DB_USER_NAME = "TCMDBUSER"
$setupvars.CM_DB_PASSWORD = $setupvars.MASTER_PASSWORD
$setupvars.CM_SYSTEM_ACCOUNT = "MTSUser"


# TTM Database Variables

$setupvars.TTM_DB_HOST = $setupvars.DB_HOST
$setupvars.TTM_DB_NAME = "Tridion_Topology"
$setupvars.TTM_DB_USER_NAME = "TTMDBUSER"
$setupvars.TTM_DB_PASSWORD = $setupvars.MASTER_PASSWORD


# Content Delivery Database Variables

$setupvars.CD_DB_HOST = $setupvars.DB_HOST
$setupvars.CD_DB_NAME = "Tridion_Broker"
$setupvars.CD_DB_USER_NAME = "TridionBrokerUser"
$setupvars.CD_DB_PASSWORD = $setupvars.MASTER_PASSWORD


# Session Preview Database Variables

$setupvars.SP_DB_HOST = $setupvars.DB_HOST
$setupvars.SP_DB_NAME = "Tridion_Broker_Preview"
$setupvars.SP_DB_USER_NAME = "TridionBrokerUser"
$setupvars.SP_DB_PASSWORD = $setupvars.MASTER_PASSWORD

# Content Manager Database 

# Single quotes are needed for when the server is set as "(local)". I guess it doesn't hurt to keep the quotes here & there

$setupvars.SQL_INSTALLER_DIR = $setupvars.TCM_INSTALLER_ROOT + "\Database\mssql\"
$cmdbcreatescript = $setupvars.SQL_INSTALLER_DIR + "Install Content Manager database.ps1"
$cmdbparameters = "-DatabaseServer '" + $setupvars.CM_DB_HOST +,
                  "' -DatabaseName '" + $setupvars.CM_DB_NAME +,
                  "' -DatabaseUserName " + $setupvars.CM_DB_USER_NAME +,
                  " -DatabaseUserPassword " + $setupvars.CM_DB_PASSWORD +,
                  " -AdministratorUserName " + $setupvars.SA_ACCOUNT + ,
                  " -AdministratorUserPassword " + $setupvars.SA_PASSWORD +,
                  " -NonInteractive"





# DATABASE CREATION SECTION

# Create Databases
Write-Host "Creating CM Database..."
cd $setupvars.SQL_INSTALLER_DIR

if(-not (IsDBInstalled($setupvars.CM_DB_NAME)))
{
    Write-Host "Database " + $setupvars.CM_DB_NAME + " doesn't exist yet, invoking SDL script"
    Invoke-Expression "& `"$cmdbcreatescript`" $cmdbparameters"
}else 
{Write-Host "Step already executed"}

# Create Topology Manager Database

$cmdbcreatescript = $setupvars.SQL_INSTALLER_DIR + "Install Topology Manager database.ps1"
$cmdbparameters = "-DatabaseServer `"" + $setupvars.TTM_DB_HOST + "`"" +,
                  " -DatabaseName " + $setupvars.TTM_DB_NAME +,
                  " -DatabaseUsers @(@{UserName=`"" + $setupvars.TTM_DB_USER_NAME + "`";UserPassword=`"" + $setupvars.TTM_DB_PASSWORD +"`"})" + ,
                  " -AdministratorUserName " + $setupvars.SA_ACCOUNT + ,
                  " -AdministratorUserPassword " + $setupvars.SA_PASSWORD +,
                  " -NonInteractive"


Write-Host "Checking if database already exists"
$dbexists = IsDBInstalled($setupvars.TTM_DB_NAME)
Write-Host "TTM Database exists? " $dbexists

if(-not $dbexists){

    Write-Host "Database " + $setupvars.TTM_DB_NAME + " doesn't exist yet, invoking SDL script"
    Invoke-Expression "& `"$cmdbcreatescript`" $cmdbparameters"
}else 
{Write-Host "Topology Manager Database already exists"}


# Create Content Delivery Database
$cmdbcreatescript = $setupvars.SQL_INSTALLER_DIR + "Install Content Data Store.ps1"
$cmdbparameters = "-DatabaseServer `"" + $setupvars.CD_DB_HOST + "`"" +,
                  " -DatabaseName " + $setupvars.CD_DB_NAME +,
                  " -DatabaseUserName " + $setupvars.CD_DB_USER_NAME +,
                  " -DatabaseUserPassword " + $setupvars.CD_DB_PASSWORD +,
                  " -AdministratorUserName " + $setupvars.SA_ACCOUNT + ,
                  " -AdministratorUserPassword " + $setupvars.SA_PASSWORD +,
                  " -NonInteractive"


Write-Host "Checking if database already exists"
$dbexists = IsDBInstalled($setupvars.CD_DB_NAME)
Write-Host "Content Delivery Database exists? " $dbexists

if(-not $dbexists){

    Write-Host "Database " + $setupvars.CD_DB_NAME + " doesn't exist yet, invoking SDL script"
    Invoke-Expression "& `"$cmdbcreatescript`" $cmdbparameters"

}else 
{Write-Host "Content Delivery Database already exists"}


# Create Session Preview Database
$cmdbcreatescript = $setupvars.SQL_INSTALLER_DIR + "Install Content Data Store.ps1"
$cmdbparameters = "-DatabaseServer `"" + $setupvars.SP_DB_HOST + "`"" +,
                  " -DatabaseName " + $setupvars.SP_DB_NAME +,
                  " -DatabaseUserName " + $setupvars.SP_DB_USER_NAME +,
                  " -DatabaseUserPassword " + $setupvars.SP_DB_PASSWORD +,
                  " -AdministratorUserName " + $setupvars.SA_ACCOUNT + ,
                  " -AdministratorUserPassword " + $setupvars.SA_PASSWORD +,
                  " -NonInteractive"


Write-Host "Checking if database already exists"
$dbexists = IsDBInstalled($setupvars.SP_DB_NAME)
Write-Host "Content Delivery Database exists? " $dbexists

if(-not $dbexists){

    Write-Host "Database " + $setupvars.SP_DB_NAME + " doesn't exist yet, invoking SDL script"
    Invoke-Expression "& `"$cmdbcreatescript`" $cmdbparameters"
}else 
{Write-Host "Content Delivery Database already exists"}



# Should be ready now to invoke CM Installer

$cmInstaller = $setupvars.TCM_INSTALLER_ROOT + "\Content Manager\SDLWeb85CM.exe"

# Enable IIS
# The beauty of this method is that it removes the default website. Reason why we add it now is so that the Tridion Installer doesn't need to add
# IIS - it sets the default website too, and then it can't use port 80.

# The next line is needed because of some odd behavior of Invoking sql commands
c:

if((Get-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online).State -eq "Disabled")
{ 

    # THIS IS OVERKILL BUT GETS THE JOB DONE

    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-WebServerRole`" -NoRestart" 
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-WebServer`" -NoRestart" 
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ApplicationInit`" -NoRestart" 
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HealthAndDiagnostics`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HttpLogging`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HttpErrors`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-BasicAuthentication`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HttpCompressionStatic`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HttpCompressionDynamic`" -NoRestart"
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-HttpTracing`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ISAPIExtensions`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ISAPIFilter`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-NetFxExtensibility45`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-RequestFiltering`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-Performance`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-Security`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-RequestMonitor`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-StaticContent`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-CommonHttpFeatures`" -NoRestart "

    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ManagementService`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-WindowsAuthentication`" -NoRestart "
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ASPNET`" -NoRestart -All "


    Invoke-Expression "Get-Website -Name `"Default Web Site`" | Remove-WebSite -Confirm:`$false -Verbose"
    Invoke-Expression "Remove-WebAppPool -Name `"DefaultAppPool`" -Confirm:`$false -Verbose"
    
}

# TODO: NEED TO FIND A WAY TO CHECK IF THIS MODULE IS INSTALLED BEFORE CALLING IT

$coreservicepsmodule = $false
if(Get-Module -ListAvailable -Name Tridion-CoreSerivce)
{    
    $coreservicepsmodule = $true
}

if($coreservicepsmodule -eq $null)
{ iwr "https://raw.githubusercontent.com/pkjaer/tridion-powershell-modules/master/CoreService/Installation/Install.ps1" | iex}


# Maybe this as a way to see if Tridion is installed?

#$tridionInstalled = Get-TridionUser -ErrorAction SilentlyContinue
$tridionInstalled = $false
if(Get-Module -ListAvailable -Name Tridion.ContentManager.Automation)
{    
    $tridionInstalled = $true
}


if($tridionInstalled -eq $false)
{ 
    # Unattended CM Install

    $cmparameters = "ACCEPT_EULA=true " +,
                "DB_NAME=" + $setupvars.CM_DB_NAME + " " +,
                "DB_PASSWORD=" + $setupvars.CM_DB_PASSWORD + " "+,
                "DB_SERVER=`"" + $setupvars.CM_DB_HOST + "`" "+,
                "DB_USER=" +$setupvars.CM_DB_USER_NAME + " "+,
                "SYSTEM_ACCOUNT_NAME=" + $setupvars.CM_SYSTEM_ACCOUNT + " "+,
                "SYSTEM_ACCOUNT_DOMAIN=" + $env:computername + " "+,
                "SYSTEM_ACCOUNT_PASSWORD=" + $setupvars.MASTER_PASSWORD + " "+,
                "LICENSE_PATH=`"" + $setupvars.CM_LICENSE_FILE + "`" "+,
                "CD_LICENSE_PATH=`"" + $setupvars.CD_LICENSE_FILE + "`" "+,
                "TTM_DB_SERVER=`"" + $setupvars.TTM_DB_HOST + "`" "+,
                "TTM_DB_NAME=" + $setupvars.TTM_DB_NAME + " "+,
                "TTM_DB_USER=" + $setupvars.TTM_DB_USER_NAME + " "+,
                "TTM_DB_PASSWORD=" + $setupvars.TTM_DB_PASSWORD + " "

    # Write-Host $cmparameters
    Write-Host "Starting CM Silent Installer - System Will Reboot when finished"
    $commandToInvoke = "& `"$cmInstaller`"" + " -s -log " + $PSScriptRoot + "\" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")) + "\cm_install.log " + " $cmparameters" 

    Invoke-Expression $commandToInvoke
}

##################### START CD INSTALL #######################

Write-Host "While the CM is installing, let's get started with CD"
Write-Host "Once the system reboots, run this script again to complete installing DXA"

# Start preparing

# check if CD was already installed

# HACK - How to find if CD Services are installed? Check for files...



if(-not (Test-Path -Path $setupvars.CD_SERVICES_ROOT))
{
# SETUP CD SERVICES

    $setupvars.CD_RESOURCES_ROOT = $setupvars.TCM_INSTALLER_ROOT + "\Content Delivery\resources"
    $setupvars.QUICK_INSTALL_ROOT = $setupvars.CD_RESOURCES_ROOT + "\quickinstall"
    $setupvars.TEMP_FOLDER = $PSScriptRoot + "\" + $(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ"))
    $quickInstall = $setupvars.QUICK_INSTALL_ROOT + "\quickinstall.ps1"


    New-Item -Path $setupvars.TEMP_FOLDER -ItemType directory
    $envfile = $setupvars.TEMP_FOLDER + "\setenv.ps1"
    New-Item -Path $envfile -ItemType file

    # Use current machine name?

    # Weirdest thing ever, this must be some sort of bug

    Add-Content $envfile "`$delivery_vars[`"c:/SDLWeb/log`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"log`""

    Add-Content $envfile "# CONTENT `n"

    Add-Content $envfile "`$delivery_vars[`"CONTENT_DEFAULT_SERVER_NAME`"] = `"$($env:computername)`""
    Add-Content $envfile "`$delivery_vars[`"CONTENT_DEFAULT_PORT_NUMBER`"] = `"$($setupvars.SQL_SERVER_PORT)`""
    Add-Content $envfile "`$delivery_vars[`"CONTENT_DEFAULT_DATABASE_NAME`"] = `"$($setupvars.CD_DB_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"CONTENT_DEFAULT_USER`"] = `"$($setupvars.CD_DB_USER_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"CONTENT_DEFAULT_PASSWORD`"] = `"$($setupvars.CD_DB_PASSWORD)`""

    Add-Content $envfile "`n# PREVIEW `n"

    Add-Content $envfile "`$delivery_vars[`"PREVIEW_DEFAULT_SERVER_NAME`"] = `"$($env:computername)`""
    Add-Content $envfile "`$delivery_vars[`"PREVIEW_DEFAULT_PORT_NUMBER`"] = `"$($setupvars.SQL_SERVER_PORT)`""
    Add-Content $envfile "`$delivery_vars[`"PREVIEW_DEFAULT_DATABASE_NAME`"] = `"$($setupvars.SP_DB_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"PREVIEW_DEFAULT_USER`"] = `"$($setupvars.SP_DB_USER_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"PREVIEW_DEFAULT_PASSWORD`"] = `"$($setupvars.SP_DB_PASSWORD)`""

    Add-Content $envfile "`n# DEPLOYER `n"
    Add-Content $envfile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_SERVER_NAME`"] = `"$($env:computername)`""
    Add-Content $envfile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_PORT_NUMBER`"] = `"$($setupvars.SQL_SERVER_PORT)`""
    Add-Content $envfile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_DATABASE_NAME`"] = `"$($setupvars.CD_DB_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_USER`"] = `"$($setupvars.CD_DB_USER_NAME)`""
    Add-Content $envfile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_PASSWORD`"] = `"$($setupvars.CD_DB_PASSWORD)`""
    Add-Content $envfile "`$delivery_vars[`"QUEUE_PATH`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"service_folder\queue\incoming`""
    Add-Content $envfile "`$delivery_vars[`"QP_FINAL_TX`"] = `$delivery_vars[`"QUEUE_PATH`"] + `"\FinalTX`""
    Add-Content $envfile "`$delivery_vars[`"QP_PREPARE`"] = `$delivery_vars[`"QUEUE_PATH`"] + `"\Prepare`""
    Add-Content $envfile "`$delivery_vars[`"BINARY_PATH`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"service_folder\binary`""

    $oldname = $setupvars.QUICK_INSTALL_ROOT + "\setenv.ps1"
    $newname = $setupvars.QUICK_INSTALL_ROOT + "\setenv-backup-$(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")).ps1"
    Rename-Item $oldname $newname
    Copy-Item $envfile $setupvars.QUICK_INSTALL_ROOT

    # here goes

    $quickInstallParameters = "-license `"" + $setupvars.CD_LICENSE_FILE + "`"" +,
                               " -enable-discovery" +,
                               " -enable-deployer-combined" +,
                               " -enable-preview" +,
                               " -enable-session" +,
                               " -auto-register" +,
                               " -target-folder `"" + $setupvars.CD_SERVICES_ROOT + "`""

    Write-Host $quickInstallParameters
    Invoke-Expression "& `"$quickInstall`" $quickInstallParameters"

}
# Now we need to add the Web Capability to the discovery service
# And copy some files around

# find discovery folder


$discoveryconfig = $setupvars.CD_SERVICES_ROOT + "\discovery\config"
$storage_conf_file = $discoveryconfig + "\cd_storage_conf.xml"

# load storage configuration
[xml]$storage = Get-Content $storage_conf_file

# Check if we have a Web Capability

$roles = $storage.Configuration.ConfigRepository.Roles
$done = $false

foreach($role in $roles.ChildNodes)
{
    if($role.GetAttribute("Name") -eq "WebCapability")
    {$done=$true}
}

if(-not $done)
{
    $newRole = $storage.CreateElement("Role")
    $storage.Configuration.ConfigRepository.Roles.AppendChild($newRole)
    $newRole.SetAttribute("Name", "WebCapability")
    $storage.Save($storage_conf_file)

    #Copy the discovery-registration jar to the config folder
    $source = $setupvars.TCM_INSTALLER_ROOT + "\Content Delivery\roles\discovery\registration\discovery-registration.jar"
    
    Copy-Item $source $discoveryconfig

    cd $discoveryconfig
    java -jar discovery-registration.jar update
}

# Now... we should wait for the machine to reboot before continuing, as we need the CM to be installed for the DXA Setup
# I'll think about this
# I guess I could create a new file and check for its existence after reboot?

    # need to find if TCM is running
    # if not, we need to exit and wait

    
if(-not($tridionInstalled))
{
    # I guess Tridion is not installed yet.
    Write-Host "Waiting for Tridion to install... will continue later, remember to run this script again after the system reboots"
    exit
}

# Crudely check if DXA is installed
Set-TridionCoreServiceSettings -Version Web-8.1
$dxainstalled = Test-TridionItem "/webdav/000%20Empty"

if(-not($dxainstalled))

{
cd $PSScriptRoot
$dxaziptarget = $PSScriptRoot + "\dxa.zip"
if(-not(Test-Path $dxaziptarget))
{
    iwr $setupvars.DXA_DOWNLOAD_URL -OutFile $dxaziptarget | Unblock-File 
    md dxa   
    $target = $PSScriptRoot + "\dxa"
    Unzip $dxaziptarget $target
}

#prepare to run ttm-prepare.ps1
# Looks like ttm-prepare cannot be run interactively
# Setting up topology for DXA:
$ttmPrepareScript = $PSScriptRoot + "\ttm-prepare-modified.ps1"
$ttmparameters = "-StagingOnly" +,
                 " -stagingWebsiteBaseUrls http://" + $env:computername.ToLower() + ":82",
                 " -discoveryServiceUrl http://" + $env:computername.ToLower() + ":8082/discovery.svc",
                 " -oauthClientId cmuser",
                 " -oauthClientSecret CMUserP@ssw0rd"

Invoke-Expression "& `"$ttmPrepareScript`" $ttmparameters"

#prepare to run tcmimport

$cmsImportParameters = "-importType all-publications" +,
                           " -cmsUrl http://" + $env:computername
$cmsImportScript = $PSScriptRoot + "\dxa\cms\cms-import.ps1"
Invoke-Expression "& `"$cmsImportScript`" $cmsImportParameters"

# now let's do the permission import
$cmsImportParameters = "-importType rights-permissions"

Invoke-Expression "& `"$cmsImportScript`" $cmsImportParameters"
}

# Last, let's check if we have anything running on port 82 (the staging site we just setup, hopefully)

$testConnection = Get-NetTCPConnection -LocalPort 82 -ErrorAction SilentlyContinue
if($testConnection -eq $null)
{

    # Let's try to setup staging
    # .\web-install.ps1 -distDestination "C:\inetpub\wwwroot\DXA_Staging" -webName "DXA Staging" -sitePort 8888 -discoveryServiceUrl http://localhost:8082/discovery.svc

    $webInstallParameters = "-distDestination `"" + $setupvars.DXA_STAGING_ROOT + "`"",
                            " -webName `"DXA Staging`"",
                            " -sitePort 82",
                            " -discoveryServiceUrl http://" + $env:computername.ToLower() + ":8082/discovery.svc"

    $webInstallScript = $PSScriptRoot + "\dxa\web\web-install.ps1"

    Invoke-Expression "& `"$webInstallScript`" $webInstallParameters"
}