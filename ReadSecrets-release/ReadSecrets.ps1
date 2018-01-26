Trace-VstsEnteringInvocation $MyInvocation

$ResourceGroupName= Get-VstsInput -Name "ResourceGroupName"
$KeyVaultName= Get-VstsInput -Name "KeyVaultName"
$secretName = Get-VstsInput -name "secretName"
$TagValue1 = Get-VstsInput -name "TagValue1"
$TagValue2 = Get-VstsInput -name "TagValue2"
$TagValue3 = Get-VstsInput -name "TagValue3"


################# Initialize Azure. #################
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

# Verify that specified Key Vault exists
try {
    $DoesKVExist = Get-AzureRmResource -ResourceName $KeyVaultName -ResourceGroupName $ResourceGroupName
}
catch {
    Write-Error "Key Vault $keyVaultName not found in resource group $ResourceGroupName"
    Trace-VstsLeavingInvocation $MyInvocation
    $host.SetShouldExit(1)
}

if (!($DoesKVExist)){
    Write-Error "Key Vault $keyVaultName not found in resource group $ResourceGroupName"
    Trace-VstsLeavingInvocation $MyInvocation
    $host.SetShouldExit(1)
}

if ($secretName) {
    # Get a single secret
    $value =  Get-AzureKeyVaultSecret -VaultName $keyVaultName -name $secretName
    if ($value) {
        Write-output "Retrieving Key Vault secret named $secretName and storing as VSTS variable"
        Write-Output "##vso[task.setvariable variable=$secretName]$($value.secretValueText)"
    }
    else {
        Write-Error "No secret named $secretName found in Key Vault named $keyVaultName"
        Trace-VstsLeavingInvocation $MyInvocation
        $host.SetShouldExit(1)
    }
}
else {
    # Get all secrets
    $AllSecrets = Get-AzureKeyVaultSecret -VaultName $keyVaultName

    # Parse Tag Values
    if ($tagvalue1 -match "=") {
        $tag1 = $TagValue1.split('=')[0]
        $value1 = $TagValue1.split('=')[1]
    }
    if ($tagvalue2 -match "=") {
        $tag2 = $TagValue2.split('=')[0]
        $value2 = $TagValue2.split('=')[1]
        }
    if ($tagvalue3 -match "=") {
        $tag3 = $TagValue3.split('=')[0]
        $value3 = $TagValue3.split('=')[1]
        }

    # Collect only those secrets that math all tagged values
    if ($tag3) { 
        $secrets += $AllSecrets | where {($_.tags.$tag1 -eq $value1) -and ($_.tags.$tag2 -eq $value2) -and ($_.tags.$tag3 -eq $value3) }
    }
    elseif ($tag2) {
        $secrets += $AllSecrets | where {($_.tags.$tag1 -eq $value1) -and ($_.tags.$tag2 -eq $value2) }
    }
    elseif ($tag1) {
        $secrets += $AllSecrets | where {($_.tags.$tag1 -eq $value1) }
    }

    if ($secrets) {

        # Get secret values and store them as VSTS variables
        foreach ($secret in $secrets) {
            $value =  Get-AzureKeyVaultSecret -VaultName $keyVaultName -name $secret.name
            Write-output "Retrieving Key Vault secret named $($secret.name) and storing as VSTS variable"
            Write-Output "##vso[task.setvariable variable=$($secret.name)]$($value.secretValueText)"
        }
    }
    else {
        Write-Error "No secrets matching the specified tags were found in Key Vault named $keyVaultName"
        Trace-VstsLeavingInvocation $MyInvocation
        $host.SetShouldExit(1)
    }
}
Trace-VstsLeavingInvocation $MyInvocation
