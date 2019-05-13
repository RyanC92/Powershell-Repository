$Groups = Get-ADGroup -Filter {Name -like "RG-Excelsior*"}

$rtn = @(); ForEach ($Group in $Groups) {
    $rtn += (Get-ADGroupMember -Identity "$($Group.Name)" -Recursive)
}