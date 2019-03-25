function Get-365UserGroupMembership {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Alias('Email')]
        [string]$UserName
    )
    $groups = Get-Group | Where-Object -FilterScript {$_.Members -contains $UserName}
    
    foreach ($group in $groups) {
        $props = @{'Name'           = $group.Name;
                   'DisplayName'    = $group.DisplayName;
                   'Identity'       = $group.SamAccountName;
                   'PrimaryEmail'   = $group.WindowsEmailAddress}

        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
    }
}