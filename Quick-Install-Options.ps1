$setupOptions.TCM_INSTALLER_PATH = "D:\Software\SDL Web 8\SDL Web 8.5"
$setupOptions.MASTER_PASSWORD = "Tr1d10n"

# GLOBAL SETTINGS

$setupOptions.SA_ACCOUNT_NAME="sa"
$setupOptions.SA_PASSWORD=$setupOptions.MASTER_PASSWORD
$setupOptions.DB_HOST="(local)"
$setupOptions.CD_LICENSE_FILE="D:\Licenses\cd_licenses.xml"
$setupOptions.CM_LICENSE_FILE="D:\Licenses\license.xml"
$setupOptions.SQL_SERVER_PORT = "1433"
$setupOptions.CD_SERVICES_ROOT = "C:\SDL\Web"
$setupOptions.URL_DXA = "https://docs.sdl.com/DXA/DotNET/1.7/Download/"
$setupOptions.URL_CORE_SERVICE_PS = "https://raw.githubusercontent.com/pkjaer/tridion-powershell-modules/master/CoreService/Installation/Install.ps1"

# CM Database Options

$setupOptions.CM_DB_HOST = $setupOptions.DB_HOST
$setupOptions.CM_DB_NAME = "Tridion_cm"
$setupOptions.CM_DB_USER_NAME = "TCMDBUSER"
$setupOptions.CM_DB_PASSWORD = $setupOptions.MASTER_PASSWORD
$setupOptions.CM_SYSTEM_ACCOUNT = "MTSUser"

# Topology Manager Database Options

$setupOptions.TTM_DB_HOST = $setupOptions.DB_HOST
$setupOptions.TTM_DB_NAME = "Tridion_Topology"
$setupOptions.TTM_DB_USER_NAME = "TTMDBUSER"
$setupOptions.TTM_DB_PASSWORD = $setupOptions.MASTER_PASSWORD

# Content Delivery Broker Database

$setupOptions.CD_DB_HOST = $setupOptions.DB_HOST
$setupOptions.CD_DB_NAME = "Tridion_Broker"
$setupOptions.CD_DB_USER_NAME = "TridionBrokerUser"
$setupOptions.CD_DB_PASSWORD = $setupOptions.MASTER_PASSWORD

# Session Preview Database

$setupOptions.PREVIEW_DB_HOST = $setupOptions.DB_HOST
$setupOptions.PREVIEW_DB_NAME = "Tridion_Broker_Preview"
$setupOptions.PREVIEW_DB_USER_NAME = $setupOptions.CD_DB_USER_NAME
$setupOptions.PREVIEW_DB_PASSWORD = $setupOptions.MASTER_PASSWORD

# TCP Port Options

$setupOptions.PORT_DISCOVERY_SERVICE="8082"
$setupOptions.PORT_STAGING = 82

# CD Service URLs

$setupOptions.CD_SERVICE_URL = "http://" + $env:COMPUTERNAME.ToLower() + ":" + $setupOptions.PORT_DISCOVERY_SERVICE + "/discovery.svc"

# DXA Options

$setupOptions.DXA_WEBSITE_PATH = "c:\sdl\web\staging"

# Computed options...

$setupOptions.SQL_SCRIPTS = $setupOptions.TCM_INSTALLER_PATH + "\Database\mssql"
$setupOptions.CD_RESOURCES_PATH = $setupOptions.TCM_INSTALLER_PATH + "\Content Delivery\resources"
$setupOptions.QUICK_INSTALL_PATH = $setupOptions.CD_RESOURCES_PATH + "\quickinstall"