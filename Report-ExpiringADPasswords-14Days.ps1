# Import the Active Directory module
Import-Module ActiveDirectory

# Ensure the ImportExcel module is available
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
    Import-Module ImportExcel
}

# Define the threshold for password expiration (in days)
$daysToExpire = 14

# Calculate the date for the threshold
$currentDate = Get-Date
$thresholdDate = $currentDate.AddDays($daysToExpire)

# Get the domain's password policy max age
$passwordMaxAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Query all users in the domain
Write-Host "Querying Active Directory for users..." -ForegroundColor Cyan
$users = Get-ADUser -Filter {Enabled -eq $true} -Properties DisplayName, SamAccountName, PasswordLastSet, DistinguishedName

# Total number of users for progress tracking
$totalUsers = $users.Count
$currentIndex = 0

# Create an array to store users with expiring passwords
$expiringUsers = @()

# Process each user
foreach ($user in $users) {
    # Increment progress index
    $currentIndex++

    # Display progress bar
    Write-Progress -Activity "Processing Users..." -Status "User $currentIndex of $totalUsers" -PercentComplete (($currentIndex / $totalUsers) * 100)

    # Skip users who have never set their password
    if (-not $user.PasswordLastSet) {
        continue
    }

    # Calculate the password expiration date
    $passwordExpirationDate = $user.PasswordLastSet + $passwordMaxAge

    # Extract the desired OU (e.g., "New Jersey") from the DistinguishedName
    $ouPattern = "(?<=,OU=)([^,]+)" # Regex to match the first OU
    $ouMatches = [regex]::Matches($user.DistinguishedName, $ouPattern)
    $userOU = if ($ouMatches.Count -ge 2) { $ouMatches[1].Value } else { "Unknown OU" }

    # Check if the password is expiring within the threshold
    if ($passwordExpirationDate -lt $thresholdDate -and $passwordExpirationDate -gt $currentDate) {
        $expiringUsers += [PSCustomObject]@{
            DisplayName          = $user.DisplayName
            SamAccountName       = $user.SamAccountName
            OrganizationalUnit   = $userOU
            PasswordExpiration   = $passwordExpirationDate
        }
    }
}

# Generate timestamp for file naming
$timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm")

# Export the detailed report to an XLSX file with table style
$reportPath = "C:\Reports\ExpiringPasswordsReport_$timestamp.xlsx"
if (-not (Test-Path "C:\Reports")) {
    New-Item -Path "C:\Reports" -ItemType Directory -Force
}
$expiringUsers | Sort-Object PasswordExpiration | Export-Excel -Path $reportPath -WorksheetName "Detailed Report" -TableStyle Medium16 -AutoSize
Write-Host "Detailed report generated: $reportPath" -ForegroundColor Green
