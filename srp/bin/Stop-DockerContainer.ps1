#===============================================#
# LogRhythm SE Operations                       #
# Docker Remediation SmartResponse Script       #
# alex.kagno@logrhythm.com                      #
#                                               #
# v1.0  --  June, 2020                          #
# Copyright 2020 LogRhythm Inc.                 #
#===============================================#  

#requires -version 3.0

Param(
    [Parameter( Mandatory = $true, ValueFromPipeline = $true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string] $TargetHost,

    [Parameter(Mandatory=$true, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string] $TargetUser,

    [Parameter(Mandatory=$true, Position=2)]
    [ValidateNotNullOrEmpty()]
    [string] $PrivKeyPath,
    
    [Parameter(Mandatory=$true, Position=3)]
    [ValidateNotNullOrEmpty()]
    [string] $Object
)

# Requires Posh-SSH due to compatability issues with SSH on older versions of Windows
Import-Module Posh-SSH

$Credential = [PSCredential]::New($TargetUser, [securestring]::new())

# Establish General Error object Output
$ErrorObject = [PSCustomObject]@{
    Error                 =   $false
    Type                  =   $null
    Code                  =   $null
    Note                  =   $null
}

# Establish the SSH session
try {
    $Session = New-SSHSession -AcceptKey -ComputerName $TargetHost -Credential $Credential -KeyFile $PrivKeyPath
}
catch {
    $ErrorObject.Error = $true
    $ErrorObject.Type = $_.CategoryInfo.TargetName.ToString()
    $ErrorObject.Note = $_.Exception
    return $ErrorObject
}

# Craft the command string
$Command = "docker stop $Object" 

# Invoke the SSH command
$Response = Invoke-SSHCommand -Command $Command -SessionId $Session.SessionId
if ($Response.ExitStatus -ne 0){
    $ErrorObject.Error = $true
    $ErrorObject.Code = $Response.ExitStatus
    $ErrorObject.Note = $Response.Output
    return $ErrorObject
} elseif (-not $Response){
    $ErrorObject.Error = $true
    $ErrorObject.Type = $null
    $ErrorObject.Note = "No response received from the SSH, are you using the correct session ID?"
} else {
    Write-Verbose "Container $Object stopped successfully."
}
