# Set variables

$computerName = "TESTAOS01,TESTAOS02" -split ','
$AXBCpath = "C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin\Microsoft.Dynamics.BusinessConnectorNet.dll"

# Validate Administrative privileges and Elevated command prompt

Write-Host "Validating security privileges... " -NoNewline

if (-NOT [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))
{
    throw "You must be running the script in an Elevated command prompt using the Run as administrator option!"
}

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    throw "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"    
}

Write-Host "Done" -ForegroundColor Yellow

# Script for checking AIF

[ScriptBlock] $global:CheckAIFPorts =
{
    param ([string] $AXBCpath)
    try
    {
        $bcassembly = [Reflection.Assembly]::Loadfile($AXBCpath)      
        $ax = new-object Microsoft.Dynamics.BusinessConnectorNet.Axapta
        $ax.logon("","","","")
        $xSession = $ax.CreateAxaptaObject("XSession")   
        $AOSName = $xSession.call("AOSName")
        
        Write-Host -NoNewline "$AOSName AIF ports are ... "
        if ($ax.CallStaticClassMethod("Global", "WIK_notStartedAIFPortExists") -eq $false)
        #if ($ax.CallStaticClassMethod("Global", "isaos") -eq $true) #"WIK_notStartedAIFPortExists")
        {
            Write-Host "OK" -ForegroundColor Yellow
        }
        else
        {
            Write-Host "NOT OK" -ForegroundColor Red
        }
        $logedOff = $ax.logoff()
    }
    catch [Exception]
    {
	    Write-Host "Failed" -ForegroundColor Red
	    Write-Host $_.exception.message
    }
}

$Session = New-PSSession -ComputerName $computerName
Invoke-Command -Session $Session -ScriptBlock $CheckAIFPorts -ArgumentList "$AXBCpath"
Remove-PSSession -Session $Session