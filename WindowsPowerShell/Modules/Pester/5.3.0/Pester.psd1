@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'Pester.psm1'

    # Version number of this module.
    ModuleVersion     = '5.3.0'

    # ID used to uniquely identify this module
    GUID              = 'a699dea5-2c73-4616-a270-1f7abb777e71'

    # Author of this module
    Author            = 'Pester Team'

    # Company or vendor of this module
    CompanyName       = 'Pester'

    # Copyright statement for this module
    Copyright         = 'Copyright (c) 2021 by Pester Team, licensed under Apache 2.0 License.'

    # Description of the functionality provided by this module
    Description       = 'Pester provides a framework for running BDD style Tests to execute and validate PowerShell commands inside of PowerShell and offers a powerful set of Mocking Functions that allow tests to mimic and mock the functionality of any command inside of a piece of PowerShell code being tested. Pester tests can execute any command or script that is accessible to a pester test file. This can include functions, Cmdlets, Modules and scripts. Pester can be run in ad hoc style in a console or it can be integrated into the Build scripts of a Continuous Integration system.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess    = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess  = @('Pester.Format.ps1xml', 'PesterConfiguration.Format.ps1xml')

    # Functions to export from this module
    FunctionsToExport = @(
        'Invoke-Pester'

        # blocks
        'Describe'
        'Context'
        'It'

        # mocking
        'Mock'
        'InModuleScope'

        # setups
        'BeforeDiscovery'
        'BeforeAll'
        'BeforeEach'
        'AfterEach'
        'AfterAll'

        # should
        'Should'
        'Add-ShouldOperator'
        'Get-ShouldOperator'

        # export
        'Export-NUnitReport'
        'ConvertTo-NUnitReport'
        'Export-JUnitReport'
        'ConvertTo-JUnitReport'
        'ConvertTo-Pester4Result'

        # config
        'New-PesterContainer'
        'New-PesterConfiguration'

        # legacy
        'Assert-VerifiableMock'
        'Assert-MockCalled'
        'Set-ItResult'
        'New-MockObject'

        'New-Fixture'
    )

    # # Cmdlets to export from this module
    CmdletsToExport   = ''

    # Variables to export from this module
    VariablesToExport = @()

    # # Aliases to export from this module
    AliasesToExport   = @(
        'Add-AssertionOperator'
        'Get-AssertionOperator'
    )


    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    PrivateData       = @{
        # PSData is module packaging and gallery metadata embedded in PrivateData
        # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
        # We had to do this because it's the only place we're allowed to extend the manifest
        # https://connect.microsoft.com/PowerShell/feedback/details/421837
        PSData                  = @{
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category     = "Scripting Techniques"

            # Keyword tags to help users find this module via navigations and search.
            Tags         = @('powershell', 'unit_testing', 'bdd', 'tdd', 'mocking', 'PSEdition_Core', 'PSEdition_Desktop', 'Windows', 'Linux', 'MacOS')

            # The web address of an icon which can be used in galleries to represent this module
            IconUri      = 'https://raw.githubusercontent.com/pester/Pester/master/images/pester.PNG'

            # The web address of this module's project or support homepage.
            ProjectUri   = "https://github.com/Pester/Pester"

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri   = "https://www.apache.org/licenses/LICENSE-2.0.html"

            # Release notes for this particular version of the module
            ReleaseNotes = 'https://github.com/pester/Pester/releases/tag/5.3.0'

            # Prerelease string of this module
            Prerelease   = ''
        }

        # Minimum assembly version required
        RequiredAssemblyVersion = '5.3.0'
    }

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

# SIG # Begin signature block
# MIIZbgYJKoZIhvcNAQcCoIIZXzCCGVsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcOgq00P0lOrv4Dtbw9k1AL10
# gd6gghR8MIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMxMDEw
# NjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2UtAxQ
# tSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4CGPN4
# bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xObTOK
# fF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wODMSlK
# XAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwfoYer
# vnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgwggG0
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEWG2h0
# dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4prtLk
# YaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYDVR0f
# BGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJl
# ZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0CiNH
# o6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1UUp4
# eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2QzI2h
# F3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnYIpp1
# FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oNcX6X
# t/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBQ0wggP1
# oAMCAQICEAPBBFtdmcD9x4iXgGyKU+cwDQYJKoZIhvcNAQELBQAwcjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQTAeFw0yMTAxMjgwMDAwMDBaFw0yNDAxMzEyMzU5NTlaMEsxCzAJ
# BgNVBAYTAkNaMQ4wDAYDVQQHEwVQcmFoYTEVMBMGA1UECgwMSmFrdWIgSmFyZcWh
# MRUwEwYDVQQDDAxKYWt1YiBKYXJlxaEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQC154nkzSQ95K1yCflVL3iFQhzw/25ht4o506hK7ATFgvP71ZI+YHce
# gvVoMtaMhJp2/EzXsgxDF7EZBR4Hl9vNbIpLAFSVCK4GBD0DxNCDFrJTPtNohgsA
# STNMcK6t0iunh7MEkaYt1yPgiISA1vcQUMKi51WSUxeWnsUNTkJDZkyM61fETbhy
# CI66xLItaf3OWdyjiOFPq2n8yx+eg1w7GCC/eNYVAjzqtSmiE/xv6Qoj7z9qFyS1
# pAO4cxDRLAD9IcCiYmHOJVgsho3/u4QNNm72ghz7iiRAO5lDoBcZIiLS5RKxJwMG
# nnYbIiAuISZmv4PtrkcSu81Lzmtu81idAgMBAAGjggHEMIIBwDAfBgNVHSMEGDAW
# gBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAdBgNVHQ4EFgQUF2nEZEX1uTrPSD3h5VSJ
# 8g9ef20wDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1Ud
# HwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3Vy
# ZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hh
# Mi1hc3N1cmVkLWNzLWcxLmNybDBLBgNVHSAERDBCMDYGCWCGSAGG/WwDATApMCcG
# CCsGAQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQB
# MIGEBggrBgEFBQcBAQR4MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBOBggrBgEFBQcwAoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB
# /wQCMAAwDQYJKoZIhvcNAQELBQADggEBANuuPZ7LhU/v1GDprUhYch3/fov3sIxp
# wshFvufWbGxUYzxEVQSsZLdFVUzAdsCz3fKInY2ihCwqIoU5vbwKFvV1zvizat/r
# aNn5aa8H34NjEXPHQiyNykOk9CdFgk+zZn+YpeyzBMAEvQR4uB4eDv1USWkwdXPB
# VVZcjM0xEsx9H/ZZRSEGS0x3ue+shvZdPRzoWcuiK8hNcbFZr15hMGi4s0F9IxTZ
# QzoSpNJsBA/vMmkbp2SWeENn49BNx8q760e+ELMfuSBltKs8S2hB9TLrpko3nIvp
# l1323zyR6ZpWK1/FHbGkHRsSJKvOOBdlSL08+KM2kNzXez88eUae+1YwggUwMIIE
# GKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAe
# Fw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9ML
# MUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWs
# DnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeK
# iUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5Tsx
# HM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sI
# ZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/Rnf
# JZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQE
# AwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAE
# SDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGln
# aWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPA
# YPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZI
# hvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0P
# xK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK
# 95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6
# aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lF
# luhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmC
# SfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggUxMIIEGaADAgECAhAKoSXW
# 1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xNjAxMDcxMjAw
# MDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERp
# Z2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC90DLuS82Pf92puoKZxTlUKFe2I0rEDgdF
# M1EQfdD5fU1ofue2oPSNs4jkl79jIZCYvxO8V9PD4X4I1moUADj3Lh477sym9jJZ
# /l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4iPw7/fpX786O6Ij4YrBHk8JkDbTuFfAnT
# 7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3fQDpct1HhoXkUxk0kIzBdvOw8YGqsLwfM
# /fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9lCosp+R1PrqYD4R/nzEU1q3V8mTLex4F
# 0IQZchfxFwbvPc3WTe8GQv2iUypPhR3EHTyvz9qsEPXdrKzpVv+TAgMBAAGjggHO
# MIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S5GGlsqIlssgXNW4wHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
# Af8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgweQYIKwYBBQUHAQEEbTBrMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKG
# N2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwUAYD
# VR0gBEkwRzA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4IB
# AQBxlRLpUYdWac3v3dp8qmN6s3jPBjdAhO9LhL/KzwMC/cWnww4gQiyvd/MrHwwh
# Wiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4stHYfBli6F6CJR7Euhx7LCHi1lssFDVD
# BGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1iRiSHY4yRUiyvKYnleB/WCxSlgNcSR3Cz
# ddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzIAbG5KHW3mWOFIoxhynmUfln8jA/jb7UB
# JrZspe6HUSHkWGCbugwtK22ixH67xCUrRwIIfEmuE7bhfEJCKMYYVs9BNLZmXbZ0
# e/VWMyIvIjayS6JKldj1po5SMYIEXDCCBFgCAQEwgYYwcjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmlu
# ZyBDQQIQA8EEW12ZwP3HiJeAbIpT5zAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU9jUgj9pPzQcp
# eVfvjvfM+n0e1VcwDQYJKoZIhvcNAQEBBQAEggEADBB/igq5WLu33QRXM5xHhCTp
# mhINXhgxSVSCFVWc+xocP7uIu7tJLQtT5c2NBVSBN3LPV/5T9OZOjYDSAA11Lqd/
# EqiEpktIxiHGXxuLAlxkC6yDsxYZiKRId2dtQtXnrECVK2JAARmPgVFHp3IRVUWS
# T+jRLkbTJcesP0qIQYsfJcZO6yHZRxr0zm+prVmoGrOpvL6ED2VDU23Zm3u0i78v
# mjhziwy4z+uW+IQwYK71DkpvLHTGhYxi2n+/4CZ/zCffYiFgQu0dg/6JuWxYuw4+
# wFCZleRP8hJREp3GXg+j64rcXKDcKohAjFyOFQcpInbvWaQz3Q5eOwknCKfgjaGC
# AjAwggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5n
# IENBAhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEwODE3MDgzMzA5WjAv
# BgkqhkiG9w0BCQQxIgQg9WWLsMcIw4OBsn12X+DIxqxPcSOyOOiNnjenvRH0ADIw
# DQYJKoZIhvcNAQEBBQAEggEAiL8oPCseMF6vzRLaX/8qU4UchoXMXmDHeJeJMjoI
# hsAFwapPidGSn/rOiHreYOyxdAZeFIbURa14UbuFd51oCua/Vt5mWO17Hfy+P39q
# lr+Zb8Nf1gEfeflCib5EpUI7VVo6nJL+vs6UD8zUiG0gbZstlGkZ6atURGzIILs3
# qgzFUfVHZojN/bQBkgcP59TEx/5J7AkCOrzQ38asmK0rJdB99Gp3VjsusViCLui8
# HYZsIquONxtLwcI3SuYDC1D2v64G+5U602xj4uG/CcuvdqtMnFoCVbEHDSTZBn6f
# ZZzWgb/wcd80BBEJnrj1w5DSqqab+EC46gDZdLZQwrUAPw==
# SIG # End signature block
