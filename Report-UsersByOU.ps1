#Get all users by OU and split each OU into its own CSV up to a limit of 500 users per CSV
#By Ryan Curran
#4/16/24
###########################################################################################

# Connect to Active Directory
Import-Module ActiveDirectory

# Define an array to store the list of "user" OUs
$userOUs = @()

# Retrieve all OUs in Active Directory
$OUs = Get-ADOrganizationalUnit -Filter * | select DistinguishedName

# Iterate through each OU and check if it's a "user" OU
foreach ($OU in $OUs) {
    if ($OU.DistinguishedName -like "*OU=Users*") {  # You can adjust this condition based on your OU naming convention
        $userOUs += $OU
    }
}

# Output the list of "user" OUs
$userOUs

# Define the maximum number of users per CSV file
$maxUsersPerFile = 500

# Initialize a counter for file numbering
$fileNumber = 1

Foreach ($UserOU in $UserOUs){
    # Get users from the specified OU
    Write-Host "Collecting names from $UserOU`n"
    $users = Get-ADUser -Filter {ObjectClass -eq "User" -and Enabled -eq "True"} -SearchBase "$($UserOU.DistinguishedName)" -Properties Givenname, Surname | Select GivenName, Surname, UserPrincipalName

    # Split the string by comma and get the second element
    $ouElements = $UserOU.DistinguishedName -split ","
    $desiredPart = $ouElements[1]

    # Split the desired part by "=" and get the last element
    $desiredPart = ($desiredPart -split "=")[-1]

    # Trim any leading or trailing spaces
    $desiredPart = $desiredPart.Trim()

    # Output the result
    Write-Host "Creating CSVs for $desiredPart`n"
    Write-Output $desiredPart
    $fileNumber = "{0:D2}" -f 01
    # Loop through users and export them to CSV files
    for ($i = 0; $i -lt $users.Count; $i += $maxUsersPerFile) {
        # Calculate the upper limit for this iteration
        $upperLimit = [Math]::Min($i + $maxUsersPerFile, $users.Count)

        # Select users for this iteration
        $usersSubset = $users[$i..($upperLimit - 1)]

        # Export users to CSV
        Write-Host "Creating ${desiredPart}_${filenumber}.csv`n"
        $csvFileName = "C:\Temp\${desiredPart}_${filenumber}.csv"
        $usersSubset | Export-Csv -Path $csvFileName -NoTypeInformation

        # Increment the file number for the next iteration
        $fileNumber = [int]$fileNumber + 1
        $fileNumber = "{0:D2}" -f $fileNumber
    }
}