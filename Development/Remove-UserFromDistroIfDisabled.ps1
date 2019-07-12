$Members = Get-ADGroupMember -Identity "All Excelsior Employees"

ForEach($Member in $members){

    $DisabledUsers = Get-ADuser -Identity $Member.SamAccountName -property emailaddress
    $NoEmail = Get-aduser -Filter {Emailaddress -Notlike "*"} -Properties Emailaddress

    ForEach($NoE in $noemail){

        $NoE.SamAccountName

    }

}
