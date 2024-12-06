$SqlInstance = "$($env:COMPUTERNAME)\SQLExpress)"
$DatabaseName = 'PoshAssetManagement'
$DbaDatabase = @{
    SqlInstance   = $SqlInstance
    Name          = $DatabaseName
    RecoveryModel = 'Simple'
}
New-DbaDatabase  @DbaDatabase