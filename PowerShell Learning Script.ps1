# PowerShell Learning Script

# 1. Basics:

# -------------

Write-Host "Hello, World!" -ForegroundColor Green

# Variables:

$name = "John"

Write-Host "Hello, $name!"

# Arrays:

$numbers = 1, 2, 3, 4, 5

Write-Host "The third number in the array is: $($numbers[2])"

# 2. Control Structures:

# -------------------------

# If statement:

$age = 25

if ($age -lt 20) {

Write-Host "You are a teenager."

} elseif ($age -lt 30) {

Write-Host "You are in your twenties."

} else {

Write-Host "You are older than 30."

}

# For loop:

for ($i=0; $i -lt 5; $i++) {

Write-Host "Loop iteration: $i"

}

# 3. Functions:

# ---------------

function Greet-User {

param (

[string]$username = "Guest"

)

Write-Host "Hello, $username!"

}

# Calling a function:

Greet-User -username "Alice"

# 4. Working with Files:

# -------------------------

# Creating a new file:

New-Item -Path 'C:\temp\example.txt' -ItemType File -Force

# Writing to a file:

Add-Content -Path 'C:\temp\example.txt' -Value 'This is a sample text.'

# Reading from a file:

$content = Get-Content -Path 'C:\temp\example.txt'

Write-Host "Content of the file: $content"

# 5. Error Handling:

# ---------------------

try {

$result = 1/0 # This will cause an error (division by zero)

} catch {

Write-Host "An error occurred: $_" -ForegroundColor Red

}

# 6. Explore More:

# -----------------

# You can explore more commands and their details using 'Get-Command' and 'Get-Help':

# Get-Command

# Get-Help <CommandName>