function Update-EveryModule {
    <#
    .SYNOPSIS
    Updates all modules from the PowerShell gallery.
    .DESCRIPTION
    Updates all local modules that originated from the PowerShell gallery.
    Removes all old versions of the modules.
    .PARAMETER ExcludedModules
    Array of modules to exclude from updating.
    .PARAMETER SkipMajorVersion
    Skip major version updates to account for breaking changes.
    .PARAMETER KeepOldModuleVersions
    Array of modules to keep the old versions of.
    .PARAMETER ExcludedModulesforRemoval
    Array of modules to exclude from removing old versions of.
    The Az module is excluded by default.
    .EXAMPLE
    Update-EveryModule -excludedModulesforRemoval 'Az'
    .NOTES
    Created by Barbara Forbes
    @ba4bes
    .LINK
    https://4bes.nl
    #>
    [cmdletbinding(SupportsShouldProcess = $true)]
    param (
        [parameter()]
        [array]$ExcludedModules = @(),
        [parameter()]
        [switch]$SkipMajorVersion,
        [parameter()]
        [switch]$KeepOldModuleVersions,
        [parameter()]
        [array]$ExcludedModulesforRemoval = @("Az")
    )
    # Get all installed modules that have a newer version available
    Write-Verbose "Checking all installed modules for available updates."
    $CurrentModules = Get-InstalledModule | Where-Object { $ExcludedModules -notcontains $CurrentModule.Name -and $CurrentModule.repository -eq "PSGallery" }

    # Walk through the Installed modules and check if there is a newer version
    foreach ( $CurrentModule in $CurrentModules) {
        Write-Verbose "Checking $($CurrentModule.Name)"
        try {
            $GalleryModule = Find-Module -Name $CurrentModule.Name -Repository PSGallery -ErrorAction Stop
        }
        catch {
            Write-Error "Module $($CurrentModule.Name) not found in gallery $CurrentModule"
            $GalleryModule = $null
        }
        try {
            $CurrentVersion = [System.Version]::New("$($CurrentModule.Version)")           
            $GalleryVersion = [System.Version]::New("$($GalleryModule.Version)")
        }
        catch {
            $GalleryVersion = $null
        }
        if ($GalleryVersion -gt $CurrentVersion) {
            if ($SkipMajorVersion -and $GalleryModule.Version.Split('.')[0] -gt $CurrentModule.Version.Split('.')[0]) {
                Write-Warning "Skipping major version update for module $($CurrentModule.Name). Galleryversion: $($GalleryModule.Version), local version $($CurrentModule.Version)"
            }
            else {
                Write-Verbose "$($CurrentModule.Name) will be updated. Galleryversion: $($GalleryModule.Version), local version $($CurrentModule.Version)"
                try {
                    if ($PSCmdlet.ShouldProcess(
                        ("Module {0} will be updated to version {1}" -f $CurrentModule.Name, $GalleryModule.Version),
                            $CurrentModule.Name,
                            "Update-Module"
                        )
                    ) {
                        Update-Module $CurrentModule.Name -ErrorAction Stop -Force
                        Write-Verbose "$($CurrentModule.Name)  has been updated"
                    }
                }
                catch {
                    Write-Error "$($CurrentModule.Name) failed: $CurrentModule "
                    continue

                }
                if ($KeepOldModuleVersions -ne $true) {
                    Write-Verbose "Removing old module $($CurrentModule.Name)"
                    if ($ExcludedModulesforRemoval -contains $CurrentModule.Name) {
                        Write-Verbose "$($allversions.count) versions of this module found [ $($module.name) ]"
                        Write-Verbose "Please check this manually as removing the module can cause instabillity."
                    }
                    else {
                        try {
                            if ($PSCmdlet.ShouldProcess(
                                ("Old versions will be uninstalled for module {0}" -f $CurrentModule.Name),
                                    $CurrentModule.Name,
                                    "Uninstall-Module"
                                )
                            ) {
                                Get-InstalledModule -Name $CurrentModule.Name -AllVersions
                                | Where-Object { $CurrentModule.version -ne $GalleryModule.Version }
                                | Uninstall-Module -Force -ErrorAction Stop
                                Write-Verbose "Old versions of $($CurrentModule.Name) have been removed"
                            }
                        }
                        catch {
                            Write-Error "Uninstalling old module $($CurrentModule.Name) failed: $_"
                        }
                    }
                }
            }
        }
        elseif ($null -ne $GalleryModule) {
            Write-Verbose "$($CurrentModule.Name) is up to date"
        }
    }
}
