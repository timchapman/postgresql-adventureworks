#Requires -Modules Az.PostgreSQL

if(-not(Get-AzResourceProvider -ProviderNamespace Microsoft.DBforPostgreSQL))
{
    Register-AzResourceProvider -ProviderNamespace Microsoft.DBforPostgreSQL
}

function create-azpgflexibleserver
{
param(
    $RGName = "timchappgrg2",
    $Location = "eastus",
    $PGServerName = "timchappgsql2" ,
    $PGAdminUserName = "timchapman",
    $PGAdminPassword,
    $PGSku = "Standard_D2s_v3",
    $PGSkuTier = "GeneralPurpose",
    $PGVersion = 12 ,
    $PGStorageInMb = 32768
)
    if(-not(get-azcontext))
    {
        Login-AzAccount
    }

    #servername must be lowercase or the deployment will fail.
    $PGServerName = $PGServerName.ToLower()

    if(-not(Get-AzResourceGroup -Name $RGName -Location $Location -ErrorAction Ignore))
    {
        New-AzResourceGroup -Name $RGName -Location $Location
    }

    [SecureString]$Password = ConvertTo-SecureString $PGAdminPassword -AsPlainText -Force
    $PostgreSQLParams = @{}

    $PostgreSQLParams.Name = $PGServerName
    $PostgreSQLParams.ResourceGroupName = $RGName
    $PostgreSQLParams.Location = $Location
    $PostgreSQLParams.AdministratorUsername = $PGAdminUserName 
    $PostgreSQLParams.AdministratorLoginPassword = ConvertTo-SecureString $PGAdminPassword -AsPlainText -Force
    $PostgreSQLParams.SkuTier = $PGSkuTier
    $PostgreSQLParams.Sku = $PGSku
    $PostgreSQLParams.Version = $PGVersion 
    $PostgreSQLParams.StorageInMb = $PGStorageInMb
    $PostgreSQLParams.PublicAccess = "None"
    $PGServerObject = New-AzPostgreSqlFlexibleServer @PostgreSQLParams
    
    $MyIPAddress = Invoke-RestMethod http://ipinfo.io/json | select -exp ip
    $FirewallRuleName = "pgallowedips-$PGServerName"
    $FirewallRules = @{}
    $FirewallRules.ResourceGroupName = $RGName 
    $FirewallRules.ServerName = $PGServerName      
    $FirewallRules.FirewallRuleName = $FirewallRuleName 
    $FirewallRules.StartIpAddress = $MyIPAddress 
    $FirewallRules.EndIpAddress = $MyIPAddress

    $ServerFirewallRule = New-AzPostgreSqlFlexibleServerFirewallRule @FirewallRules

    return $PGServerObject
}

$PGParams = @{}
$PGParams.ResourceGroupName = "timchappgtest6"
$PGParams.Location = "eastus2"
$PGParams.PGServerName = "timchapflexpgtest6"
$PGParams.PGAdminUserName = "timchapman"
$PGParams.$PGAdminPassword = "Password12345!!" 

$PGFlexServer = create-azpgflexibleserver @$PGParams

Write-Host "Server Full Name:  $($PGFlexServer.FullyQualifiedDomainName)"
