#Requires -RunAsAdministrator

############################################
# Script to deploy ALL of SDL Web 8.5 in one go
# No more fiddling with 6 or 7 confusing scripts
# Run once (well, actually twice) and get done with it
############################################
# Author:  Nuno Linhares
# Email:   nlinhares@sdl.com
# License: WTFPL - http://wtfpl.net
############################################


# Global Variables
$setupOptions = @{}

# Load configuration options
if(Test-Path ($PSScriptRoot + "\Quick-Install-Options.ps1"))
{    Invoke-Expression ($PSScriptRoot + "\Quick-Install-Options.ps1")}
else
{
    Write-Error "Could not find Quick-Install-Options.ps1 - manually check?"
    exit
}


################################################################################
#
# FUNCTIONS AND SHIT SECTION
#
################################################################################
#Quick Install Functions

Function IsDatabaseAvailable([string]$DBName)
{
    $result = Invoke-Sqlcmd ("SELECT [name] from sys.databases WHERE [name] = '$DBNAME'")
    return $result.ItemArray.Count -ge 1
    c:
}

Function IsIISAvailable()
{
    return (Get-WindowsOptionalFeature -FeatureName IIS-WebServerRole -Online).State -eq "Enabled"

}

Function IsTridionInstalled()
{
    if((Get-Module -ListAvailable -Name Tridion.ContentManager.Automation) -eq $null)
    {
        return $false
    }
    return $true
}

Function IsJavaHomeSet()
{
    $test = $env:JAVA_HOME
    if($test -eq $null)
    {
        return $false
    }
    return $true
}

Function IsDiscoveryServiceAvailable()
{
    $test = Get-NetTCPConnection -LocalPort $setupOptions.PORT_DISCOVERY_SERVICE -ErrorAction SilentlyContinue
    if($test -eq $null)
    {
        return $false
    }
    return $true
}

Function IsWebCapabilityAvailable()
{
    $storageConfFile = $setupOptions.CD_SERVICES_ROOT + "\discovery\config\cd_storage_conf.xml"
    [xml]$storageConf = Get-Content $storageConfFile

    $roles = $storageConf.Configuration.ConfigRepository.Roles
    foreach($role in $roles.ChildNodes)
    {
        if($role.GetAttribute("Name") -eq "WebCapability")
        {
            return $true
        }
    }
    return $false
}

Function IsCoreServiceModuleAvailable()
{
    if(Get-Module -ListAvailable -Name Tridion-CoreService)
    {
        $test = Get-Module Tridion-CoreService
        if($test -eq $null) {Import-Module Tridion-CoreService}
        return $true
    }

    return $false
}

Function IsDxaCmInstalled()
{
    Set-TridionCoreServiceSettings -Version Web-8.1
    return Test-TridionItem "/webdav/000%20Empty"
}

Function IsStagingRunning()
{
    $test = Get-NetTCPConnection -LocalPort $setupOptions.PORT_STAGING -ErrorAction SilentlyContinue
    if($test -eq $null)
    {
        return $false
    }
    return $true
}

Function InstallContentManagerDatabase()
{
    $cmdbscript = $setupOptions.SQL_SCRIPTS + "\Install Content Manager Database.ps1"
    $cmdbparameters = " -DatabaseServer '" + $setupOptions.CM_DB_HOST + "'",
                      " -DatabaseName '" + $setupOptions.CM_DB_NAME + "'",
                      " -DatabaseUserName " + $setupOptions.CM_DB_USER_NAME,
                      " -DatabaseUserPassword " + $setupOptions.CM_DB_PASSWORD,
                      " -AdministratorUserName " + $setupOptions.SA_ACCOUNT_NAME,
                      " -AdministratorUserPassword " + $setupOptions.SA_PASSWORD,
                      " -NonInteractive"

    cd $setupOptions.SQL_SCRIPTS

    Invoke-Expression "& `"$cmdbscript`" $cmdbparameters"
}

Function InstallTopologyManagerDatabase()
{
    $ttmdbscript = $setupOptions.SQL_SCRIPTS + "\Install Topology Manager Database.ps1"
    $ttmdbparameters = " -DatabaseServer '" + $setupOptions.TTM_DB_HOST + "'",
                      " -DatabaseName '" + $setupOptions.TTM_DB_NAME + "'",
                      " -DatabaseUsers @(@{UserName=`"" + $setupOptions.TTM_DB_USER_NAME + "`";UserPassword=`"" + $setupOptions.TTM_DB_PASSWORD + "`"})",
                      " -AdministratorUserName " + $setupOptions.SA_ACCOUNT_NAME,
                      " -AdministratorUserPassword " + $setupOptions.SA_PASSWORD,
                      " -NonInteractive"

    cd $setupOptions.SQL_SCRIPTS

    Invoke-Expression "& `"$ttmdbscript`" $ttmdbparameters"
}

Function InstallContentDeliveryDatabase()
{
    $cddbscript = $setupOptions.SQL_SCRIPTS + "\Install Content Data Store.ps1"
    $cddbparameters = " -DatabaseServer '" + $setupOptions.CD_DB_HOST + "'",
                      " -DatabaseName '" + $setupOptions.CD_DB_NAME + "'",
                      " -DatabaseUserName " + $setupOptions.CD_DB_USER_NAME,
                      " -DatabaseUserPassword " + $setupOptions.CD_DB_PASSWORD,
                      " -AdministratorUserName " + $setupOptions.SA_ACCOUNT_NAME,
                      " -AdministratorUserPassword " + $setupOptions.SA_PASSWORD,
                      " -NonInteractive"

    cd $setupOptions.SQL_SCRIPTS

    Invoke-Expression "& `"$cddbscript`" $cddbparameters"
}

Function InstallPreviewDatabase()
{
    $previewdbscript = $setupOptions.SQL_SCRIPTS + "\Install Content Data Store.ps1"
    $previewdbparameters = " -DatabaseServer '" + $setupOptions.PREVIEW_DB_HOST + "'",
                      " -DatabaseName '" + $setupOptions.PREVIEW_DB_NAME + "'",
                      " -DatabaseUserName " + $setupOptions.PREVIEW_DB_USER_NAME,
                      " -DatabaseUserPassword " + $setupOptions.PREVIEW_DB_PASSWORD,
                      " -AdministratorUserName " + $setupOptions.SA_ACCOUNT_NAME,
                      " -AdministratorUserPassword " + $setupOptions.SA_PASSWORD,
                      " -NonInteractive"

    cd $setupOptions.SQL_SCRIPTS

    Invoke-Expression "& `"$previewdbscript`" $previewdbparameters"
}

Function InstallIISPreRequisites()
{
   # $featuresNeeded = -join "IIS-WebServerRole", "IIS-WebServer", "IIS-ApplicationInit", "IIS-HealthAndDiagnostics", "IIS-HttpLogging",
   #                         "IIS-HttpErrors", "IIS-BasicAuthentication", "IIS-HttpCompressionStatic", "IIS-HttpCompressionDynamic",
   #                         "IIS-HttpTracing", "IIS-ISAPIExtensions", "IIS-ISAPIFilter", "IIS-NetFxExtensibility45", "IIS-RequestFiltering",
   #                         "IIS-Performance", "IIS-Security", "IIS-RequestMonitor", "IIS-StaticContent", "IIS-CommonHttpFeatures",
   #                         "IIS-ManagementService", "IIS-WindowsAuthentication"


   # Enable-WindowsFeatures($featuresNeeded)

   #Trying something simpler
   Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-WebServerRole`" -All -NoRestart"
}

Function Enable-WindowsFeatures([string[]] $features)
{
    foreach($feature in $features)
    {
        Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"$feature`" -NoRestart"
    }
    # DIRTY HACK, but can't do it any other way so far.
    
    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName `"IIS-ASPNET`" -NoRestart -All"
}

Function RemoveDefaultWebsite()
{
    Invoke-Expression "Get-WebBinding -Name `"Default Web Site`" | Remove-WebBinding -Confirm:`$false"
    Invoke-Expression "Get-Website -Name `"Default Web Site`" | Remove-WebSite -Confirm:`$false"
    Invoke-Expression "Remove-WebAppPool -Name `"DefaultAppPool`" -Confirm:`$false"
}

Function InstallTridionContentManager()
{
    $parameters = " -S ACCEPT_EULA=true DB_NAME="+$setupOptions.CM_DB_NAME+" DB_PASSWORD="+$setupOptions.CM_DB_PASSWORD+" DB_SERVER=`""+$setupOptions.CM_DB_HOST+"`" DB_USER="+$setupOptions.CM_DB_USER_NAME+" SYSTEM_ACCOUNT_NAME="+$setupOptions.CM_SYSTEM_ACCOUNT+" SYSTEM_ACCOUNT_DOMAIN="+$env:COMPUTERNAME+" SYSTEM_ACCOUNT_PASSWORD="+$setupOptions.MASTER_PASSWORD+" LICENSE_PATH="+$setupOptions.CM_LICENSE_FILE+" CD_LICENSE_PATH="+$setupOptions.CD_LICENSE_FILE+" TTM_DB_SERVER=`""+$setupOptions.TTM_DB_HOST+"`" TTM_DB_NAME="+$setupOptions.TTM_DB_NAME+" TTM_DB_USER="+$setupOptions.TTM_DB_USER_NAME+" TTM_DB_PASSWORD="+$setupOptions.TTM_DB_PASSWORD
    
    $cmInstaller = $setupOptions.TCM_INSTALLER_PATH + "\Content Manager\SDLWeb85CM.exe"
    $command = "& `"$cmInstaller`" $parameters"
    #Write-Host $command
    Invoke-Expression $command

}

Function Set-JavaHome()
{
    $javaExe = Find-Java
    $javaExeDir = Split-Path -Path $javaExe
    $javaHome = Split-Path -Parent $javaExeDir

    Write-Host "Found Java Home at $javaHome"
    # set JAVA_HOME for current session
    $env:JAVA_HOME = $javaHome
    # set JAVA_HOME for future sessions
    SETX JAVA_HOME $javaHome /m    
}

Function Find-Java()
{
    $javaExeSuffix = 'bin\java.exe'
    $fileSearchPaths = $env:Path.Split(';')
    $javaExePath = $fileSearchPaths |
        where {
            $potentialPath = Join-Path $_ $javaExeSuffix
            Write-Host "Testing for $potentialPath"
            if(Test-Path $potentialPath) {$potentialPath}
        } |
        select -First 1

    if($javaExePath -ne $null){
        Write-Debug "Found $javaExePath"
        return $javaExePath
    } 
 
    $registrySearchPaths = @('HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment\', 'HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment\')
    $javaExePath = $registrySearchPaths |
        where { Test-Path $_ } |
        % {
            $currentVersion = (Get-ItemProperty $_).CurrentVersion
            Write-Host "Current Java version is $currentVersion, based on $($_)"
            $versionKey = Join-Path $_ $currentVersion
            $javaHomeBasedPath = Join-Path (Get-ItemProperty $versionKey).JavaHome $javaExeSuffix
            Write-Host "Testing for $javaHomeBasedPath, based on $versionKey\JavaHome"
            if(Test-Path $javaHomeBasedPath) {$javaHomeBasedPath}
        } |
        select -First 1

    if($javaExePath -ne $null){
        Write-Debug "Found $javaExePath"
        return $javaExePath
    }
    Write-Error "Couldn't find Java... can you set JAVA_HOME by hand please?"
    exit
}


Function Install-ContentDeliveryServices()
{
    Write-Host "Preparing to install CD Services"
    $tempFolderPath = $PSScriptRoot + "\" + $(((Get-Date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ"))
    New-Item -Path $tempFolderPath -ItemType Directory
    $setenvFile = $tempFolderPath + "\setenv.ps1"
    New-Item -Path $setenvFile -ItemType File

    # Prepare setenv.ps1

    Add-Content $setenvFile "`$delivery_vars[`"c:/sdlweb/log`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"log`""
    Add-Content $setenvFile "# CONTENT `n"
    Add-Content $setenvFile "`$delivery_vars[`"CONTENT_DEFAULT_SERVER_NAME`"] = `"$($env:COMPUTERNAME.ToLower())`""
    Add-Content $setenvFile "`$delivery_vars[`"CONTENT_DEFAULT_PORT_NUMBER`"] = `"$($setupOptions.SQL_SERVER_PORT)`""
    Add-Content $setenvFile "`$delivery_vars[`"CONTENT_DEFAULT_DATABASE_NAME`"] = `"$($setupOptions.CD_DB_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"CONTENT_DEFAULT_USER`"] = `"$($setupOptions.CD_DB_USER_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"CONTENT_DEFAULT_PASSWORD`"] = `"$($setupOptions.CD_DB_PASSWORD)`""

    Add-Content $setenvFile "`n# PREVIEW `n"

    Add-Content $setenvFile "`$delivery_vars[`"PREVIEW_DEFAULT_SERVER_NAME`"] = `"$($env:COMPUTERNAME.ToLower())`""
    Add-Content $setenvFile "`$delivery_vars[`"PREVIEW_DEFAULT_PORT_NUMBER`"] = `"$($setupOptions.SQL_SERVER_PORT)`""
    Add-Content $setenvFile "`$delivery_vars[`"PREVIEW_DEFAULT_DATABASE_NAME`"] = `"$($setupOptions.PREVIEW_DB_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"PREVIEW_DEFAULT_USER`"] = `"$($setupOptions.PREVIEW_DB_USER_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"PREVIEW_DEFAULT_PASSWORD`"] = `"$($setupOptions.PREVIEW_DB_PASSWORD)`""
 
    Add-Content $setenvFile "`n# DEPLOYER `n"   

    Add-Content $setenvFile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_SERVER_NAME`"] = `"$($env:COMPUTERNAME.ToLower())`""
    Add-Content $setenvFile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_PORT_NUMBER`"] = `"$($setupOptions.SQL_SERVER_PORT)`""
    Add-Content $setenvFile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_DATABASE_NAME`"] = `"$($setupOptions.CD_DB_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_USER`"] = `"$($setupOptions.CD_DB_USER_NAME)`""
    Add-Content $setenvFile "`$delivery_vars[`"DEPLOYER_STATE_DEFAULT_PASSWORD`"] = `"$($setupOptions.CD_DB_PASSWORD)`""
    Add-Content $setenvFile "`$delivery_vars[`"QUEUE_PATH`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"\service_folder\queue\incoming`""
    Add-Content $setenvFile "`$delivery_vars[`"QP_FINAL_TX`"] = `$delivery_vars[`"QUEUE_PATH`"] + `"\FinalTX`""
    Add-Content $setenvFile "`$delivery_vars[`"QP_PREPARE`"] = `$delivery_vars[`"QUEUE_PATH`"] + `"\Prepare`""
    Add-Content $setenvFile "`$delivery_vars[`"BINARY_PATH`"] = `$delivery_vars[`"TARGET_LOCATION`"] + `"\service_folder\binary`""

    $oldname = $setupOptions.QUICK_INSTALL_PATH + "\setenv.ps1"
    $newname = $setupOptions.QUICK_INSTALL_PATH + "\setenv-backup-$(((Get-Date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")).ps1"
    
    Rename-Item $oldname $newname

    Copy-Item $setenvFile $setupOptions.QUICK_INSTALL_PATH

    Remove-Item $setenvFile
    Remove-Item $tempFolderPath 

    Write-Host "Finished preparing environment, moving to CD Quick Install"

    $quickInstallParameters = "-license `"" + $setupOptions.CD_LICENSE_FILE + "`"" +
                              " -enable-discovery" +
                              " -enable-deployer-combined" +
                              " -enable-preview" +
                              " -enable-session" +
                              " -auto-register" +
                              " -target-folder `"" + $setupOptions.CD_SERVICES_ROOT + "`""
    $quickInstallScript = $setupOptions.QUICK_INSTALL_PATH + "\quickinstall.ps1"

    Invoke-Expression "& `"$quickInstallScript`" $quickInstallParameters"

}


Function Add-WebCapability()
{
    $storageConfFile = $setupOptions.CD_SERVICES_ROOT + "\discovery\config\cd_storage_conf.xml"
    [xml]$storageConf = Get-Content $storageConfFile

    $webRole = $storageConf.CreateElement("Role")
    $storageConf.Configuration.ConfigRepository.Roles.AppendChild($webRole)
    $webRole.SetAttribute("Name", "WebCapability")
    $storageConf.Save($storageConfFile)

    $configFolder = Split-Path $storageConfFile -Parent
    $source = $setupOptions.TCM_INSTALLER_PATH + "\Content Delivery\roles\discovery\registration\discovery-registration.jar"
    Copy-Item $source $configFolder
    cd $configFolder
    java -jar discovery-registration.jar update
}

Function Install-CoreServiceModule()
{
    Invoke-WebRequest $setupOptions.URL_CORE_SERVICE_PS | iex
}

Function Unzip([string]$zipFile, [string]$outPath)
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outPath)
}

Function Install-DxaCm()
{
    $dxaPath = $PSScriptRoot + "\dxa"
    if(-not(Test-Path $dxaPath))
    {
        Write-Host "Downloading the DXA"
        $dxaDownloadTarget = $PSScriptRoot + "\dxa.zip"
        if(-not(Test-Path $dxaDownloadTarget))
        {
            Invoke-WebRequest $setupOptions.URL_DXA -OutFile $dxaDownloadTarget | Unblock-File
        }
        cd $PSScriptRoot
        md dxa
        Unzip $dxaDownloadTarget $dxaPath

    }

    # Run ttm-prepare.ps1
    
    $ttmParameters = " -stagingOnly" +
                     " -stagingWebsiteBaseUrls http://" + $env:computername.ToLower() + ":" + $setupOptions.PORT_STAGING +
                     " -discoveryServiceUrl http://" + $env:computername.ToLower() + ":" + $setupOptions.PORT_DISCOVERY_SERVICE + "/discovery.svc" + 
                     " -oauthClientId cmuser" +
                     " -oauthClientSecret CMUserP@ssw0rd"
    $ttmPrepareScript = $PSScriptRoot + "\ttm-prepare-modified.ps1"

    Invoke-Expression "& `"$ttmPrepareScript`" $ttmparameters"

    # Run TCM Import

    $cmImportParameters = " -importType all-publications" +
                          " -cmsUrl http://" + $env:computername
    $cmImportScript = $dxaPath + "\cms\cms-import.ps1"
                     
    Invoke-Expression "& `"$cmImportScript`" $cmImportParameters"

    # and now permissions

    $cmImportParameters = "-importType rights-permissions -cmsUrl http://" + $env:computername

    Invoke-Expression "& `"$cmImportScript`" $cmImportParameters"

}

Function Install-DxaCd()
{
    $webInstallParameters = "-distDestination `"" + $setupOptions.DXA_WEBSITE_PATH + "`"",
                            " -webName `"DXA Staging`"",
                            " -sitePort " + $setupOptions.PORT_STAGING,
                            " -discoveryServiceUrl http://" + $env:computername.ToLower() + ":" + $setupOptions.PORT_DISCOVERY_SERVICE + "/discovery.svc"

    $webInstallScript = $PSScriptRoot + "\dxa\web\web-install.ps1"

    Invoke-Expression "& `"$webInstallScript`" $webInstallParameters"

}

####################################################################################################################


Write-Host "######## STARTING CM Database"
if(IsDatabaseAvailable($setupOptions.CM_DB_NAME))
{
    Write-Host "Content Manager Database" $setupOptions.CM_DB_NAME "is already configured, moving on"
}
else
{
    InstallContentManagerDatabase

}

Write-Host "######## STARTING Topology Manager Database"
if(IsDatabaseAvailable($setupOptions.TTM_DB_NAME))
{
    Write-Host "Topology Manager Database" $setupOptions.TTM_DB_NAME "is already configured, moving on"
}
else
{
    InstallTopologyManagerDatabase
}

Write-Host "######## STARTING Content Delivery Database"
if(IsDatabaseAvailable($setupOptions.CD_DB_NAME))
{
    Write-Host "Content Delivery Database" $setupOptions.CD_DB_NAME "is already configured, moving on"
}
else
{
    InstallContentDeliveryDatabase
}

Write-Host "######## STARTING Preview Database"
if(IsDatabaseAvailable($setupOptions.PREVIEW_DB_NAME))
{
    Write-Host "Content Delivery Database" $setupOptions.PREVIEW_DB_NAME "is already configured, moving on"
}
else
{
    InstallPreviewDatabase
}

# Don't ASK
c:

################################
# END DATABASE SECTION
################################

################################
# START WINDOWS PREREQUISITES CRAP
################################

if(IsIISAvailable)
{
    Write-Host "IIS is already configured, moving on"
}
else
{
    Write-Host "Installing IIS Pre-requisites for Tridion Installer"
    InstallIISPreRequisites
    # Remove Default Web Site added by Windows
    Write-Host "Removing Default WebSite"
    RemoveDefaultWebSite
}

if(IsTridionInstalled)
{
    Write-Host "Tridion is already installed, let's move on to Content Delivery..."
}
else
{
    Write-Host "Preparing to install Tridion. This script will exit and your system will reboot once the installer is done."
    Write-Host "Run this script again after rebooting to continue"
    InstallTridionContentManager

    exit
}

# Check if JAVA_HOME is set

if(-not(IsJavaHomeSet))
{
    Set-JavaHome
}

# We now have java available and should be able to start installing CD. Yay.



# need to test if the services are available already
# probably best is to try to connect to discovery service?

if(-not(IsDiscoveryServiceAvailable))
{
    Install-ContentDeliveryServices
}

if(-not(IsWebCapabilityAvailable))
{
    Add-WebCapability
}

if(-not(IsCoreServiceModuleAvailable))
{
    Install-CoreServiceModule
}

if(-not(IsDxaCmInstalled))
{
    Install-DxaCm
}

if(-not(IsStagingRunning))
{
    Install-DxaCd
}