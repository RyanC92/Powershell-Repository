Function Get-FileName($InitialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.Dereferencelinks = $False
  $OpenFileDialog.initialDirectory = $initialDirectory
  #$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}

$RoleList = Get-FileName

#$AllRoles = @()

$RL = Import-csv $RoleList

ForEach($User in $RL){

    Get-Adgroupmember -Identity  $User.Role | select @{Expression = {$User.Role}; Label = "Role"},Name,SamAccountName | Export-CSV C:\CSV\MemberCount-$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -append -NoTypeinformation
    

}

<#

    $EndUsers = Get-AdgroupMember -Identity $($User.Role) | Select Name, SamAccountName

    $AllRoles += [pscustomobject]@{

        "Role" = $User.Role
        "User" = $($EndUsers.Name)
        "Username" = $($Endusers.SamAccountName)

        
    }

    $AllRoles #| Export-CSV C:\CSV\MemberCount-$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv -append -NoTypeinformation
#>