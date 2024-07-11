$logfile = "C:\Temp\PrinterError.log"
$sourceFolder = "C:\Users\rcurran\Turner Construction\Information Services - Turner Printers"
#$sourceFolder = "C:\temp\Fresno\"


function Log-Error {
    param(
        [string]$errorMessage
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - Error: $errorMessage"
    Add-Content -Path $logfile -Value $logMessage
}

# Get all subfolders in the source folder
$subFolders = Get-ChildItem $sourceFolder -Directory -Recurse

# Extract all .zip files and delete them
foreach ($subFolder in $subFolders) {
    $zipFiles = Get-ChildItem $subFolder.FullName -Filter "*.zip"
    foreach ($zipFile in $zipFiles) {
        try {
            $destinationFolder = Join-Path $subFolder.FullName ($zipFile.BaseName)
            if (!(Test-Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder | Out-Null
            }
            "Expanding $($zipfile.Fullname)"
            Expand-Archive -Path $zipFile.FullName -DestinationPath $destinationFolder -Force
            Remove-Item -Path $zipFile.FullName -Force
        } catch {
            # Catch the error and log it
            $errorMessage = $_.Exception.Message
            Log-Error -errorMessage $errorMessage
            Write-Output "An error occurred: $errorMessage"
        }
    }
}

# Search and replace text in .bat files
$batFiles = Get-ChildItem $sourceFolder -Filter "*.bat" -Recurse
foreach ($batFile in $batFiles) {
    try {
        $content = Get-Content $batFile.FullName
        $newContent = $content -ireplace "alnfile1\\Software", "tcco.org\tccofile1\Software"
        $newContent = $content -ireplace 'set "tcco.org"', 'set "host=tcco.org"'
        $newContent = $content -ireplace "tcco.org\\Software", 'tcco.org\tccofile1\Software'
        Set-Content $batFile.FullName $newContent
        "Updating $batFile.FullName to point to tccofile1"

        # Create a .zip file for the .bat file
        $folderName = Split-Path $batFile.DirectoryName -Leaf
        $zipFileName = Join-Path $batFile.Directory.Parent.FullName ($folderName + ".zip")
        "Creating $zipFileName"
        Compress-Archive -Path $batFile.FullName -DestinationPath $zipFileName

        # Delete the folder containing the .bat file
        $folderToDelete = $batFile.DirectoryName
        Remove-Item -Path $folderToDelete -Recurse -Force
    } catch {
        # Catch the error and log it
        $errorMessage = $_.Exception.Message
        Log-Error -errorMessage $errorMessage
        Write-Output "An error occurred: $errorMessage"
    }
}

Write-Output "Script finished."
