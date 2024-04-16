#Get all users by OU and split each OU into its own CSV up to a limit of 500 users per CSV
#By Ryan Curran
#4/16/24
###########################################################################################

# Connect to Active Directory
Import-Module ActiveDirectory

# Define an array to store the list of "user" OUs
$userOUs = @()

# Retrieve all OUs in Active Directory
$OUs = Get-ADOrganizationalUnit -Filter *

# Iterate through each OU and check if it's a "user" OU
foreach ($OU in $OUs) {
    if ($OU.DistinguishedName -like "*OU=Users*") {  # You can adjust this condition based on your OU naming convention
        $userOUs += $OU
    }
}

# Output the list of "user" OUs
$userOUs