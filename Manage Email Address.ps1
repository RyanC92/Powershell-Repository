

#------------------------------------------------------------------------------
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
# AUTHOR(s):
#       Eyal Doron (o365info.com)
#------------------------------------------------------------------------------
# Hope that you enjoy it ! 
# And May the force of PowerShell will be with you   :-)
# 20-4-2014    
# Version WP- 001 
#------------------------------------------------------------------------------


Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
function Validate-UserSelection
{
    Param(
        $AllowedAnswers,
        $ErrorMessage,
        $Selection
    )
    foreach($str in $AllowedAnswers.ToString().Split(","))
    {
        if($str -eq $Selection)
        {
            return $true
        }
    }
    Write-Host $ErrorMessage -ForegroundColor Red -BackgroundColor Black
    return $false

}

function Format-BytesInKiloBytes 
{
    param(
        $bytes
    )
    "{0:N0}" -f ($bytes/1000)
}

Function Set-AlternatingRows {
       <#
       
       #>
    [CmdletBinding()]
       Param(
             [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]$Line,
       
           [Parameter(Mandatory=$True)]
             [string]$CSSEvenClass,
       
        [Parameter(Mandatory=$True)]
           [string]$CSSOddClass
       )
       Begin {
             $ClassName = $CSSEvenClass
       }
       Process {
             If ($Line.Contains("<tr>"))
             {      $Line = $Line.Replace("<tr>","<tr class=""$ClassName"">")
                    If ($ClassName -eq $CSSEvenClass)
                    {      $ClassName = $CSSOddClass
                    }
                    Else
                    {      $ClassName = $CSSEvenClass
                    }
             }
             Return $Line
       }
}


$FormatEnumerationLimit = -1


#------------------------------------------------------------------------------
# PowerShell console window Style
#------------------------------------------------------------------------------

$pshost = get-host
$pswindow = $pshost.ui.rawui

	$newsize = $pswindow.buffersize
	
	if($newsize.height){
		$newsize.height = 3000
		$newsize.width = 150
		$pswindow.buffersize = $newsize
	}

	$newsize = $pswindow.windowsize
	if($newsize.height){
		$newsize.height = 50
		$newsize.width = 150
		$pswindow.windowsize = $newsize
	}

#------------------------------------------------------------------------------
# HTML Style start 
#------------------------------------------------------------------------------
$Header = @"
<style>
Body{font-family:segoe ui,arial;color:black; }
H1{ color: white; background-color:#1F4E79; font-weight:bold;width: 70%;margin-top:35px;margin-bottom:25px;font-size: 22px;padding:5px 15px 5px 10px; }
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:#0072c6 ;color:white;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
</style>

"@

#------------------------------------------------------------------------------
# HTML Style END
#------------------------------------------------------------------------------



$Loop = $true
While ($Loop)
{
    write-host 
    write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    write-host    "Manage email address | PowerShell Script menu"  
    write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    write-host
    write-host -ForegroundColor green  'Connect PowerShell session to AD Azure and Exchange Online' 
    write-host -ForegroundColor green  '--------------------------------------------------------------' 
    write-host -ForegroundColor Yellow ' 0)   Login in using your Office 365 Administrator credentials' 
    write-host
    write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section A: Add Email Address ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 1)   Set Primary email address'
	write-host 
	write-host                                              ' 2)   Set Alias Email address '
	write-host 
	write-host                                              ' 3)   Set Primary email address + Alias address '
	write-host
	write-host                                              ' 4)   Add Alias Email address - Bulk Mode'
	write-host 
	write-host                                              ' 5)   Add additional email address (alias)  to all office 365 users by using CSV File'
	write-host 
	write-host                                              ' 6)   Add X.500 Email address'
	write-host 
	write-host                                              ' 7)   Set Primary email address - public folder'
	write-host 
	
    write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section B: Remove Email Address  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 8)  Remove Alias Email address (SMTP Address)'
	write-host 
	write-host                                              ' 9)  Remove X.500 Email address '
write-host '9)   '
	
	
	
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor white  -BackgroundColor Blue 'Section C: Display/Export information about Email Addres  ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host                                              ' 10)  Display Email address information on screen - Using the Wrap parameter for a Specific Mailboxes'
	write-host 
	write-host                                              ' 11)  Display Email address information on screen - Using the Wrap parameter all Mailboxes'
	write-host 
	write-host                                              ' 12)  Export information about email address to CSV file'   
	write-host 
	write-host                                              ' 13)  Export information about email address to HTML file'   
	
		
	write-host -ForegroundColor green  '---------------------------' 
    write-host -ForegroundColor Blue  -BackgroundColor Yello ' Exit\Disconnect ' 
    write-host -ForegroundColor green  '---------------------------' 
    write-host
    write-host  -ForegroundColor Yellow                       ' 14)  Disconnect PowerShell session'
	write-host 
	write-host  -ForegroundColor Yellow                       ' 15)  Exit'
	write-host 
	write-host                                          

	

    $opt = Read-Host "Select an option [0-15]"
    write-host $opt
    switch ($opt) 


{


		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		# Step -00 |  Create a Remote PowerShell session to AD Azure and Exchange Online
		#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


		0
        {

            # Specify your administrative user credentials on the line below 

            $user = “Admin@.....”

            # This will pop-up a dialogue and request your password
            

            #——– Import the Local Microsoft Online PowerShell Module Cmdlets and  Establish an Remote PowerShell Session to AD Azure  
            
            Import-Module MSOnline

            

            #———— Establish an Remote PowerShell Session to Exchange Online ———————

            $msoExchangeURL = “https://outlook.office365.com/powershell-liveid/”
			$connected = $false
			$i = 0
			while ( -not ($connected)) {
				$i++
				if($i -eq 4){
					
										
					Write-host
					Write-host -ForegroundColor White	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					Write-host -ForegroundColor Red    "Too many incorrect login attempts. Good bye."	
					Write-host
					Write-host -ForegroundColor White	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					
					
					exit
				}
				$cred = Get-Credential -Credential $user
				try 
				{
					$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection  -ErrorAction stop
					Connect-MsolService -Credential $cred -ErrorAction stop
					Import-PSSession $session 
					$connected = $true 
				}
				catch 
				{
					Write-host
					Write-host -ForegroundColor Yellow	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
					Write-host -ForegroundColor Red     "There is something wrong with the global administrator credentials"	
					Write-host
					Write-host -ForegroundColor Yellow	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
					Write-host
				}

			}
            
			$host.ui.RawUI.WindowTitle = ("Windows Azure Active Directory |Connected to Office 365 using: " + $Cred.UserName.ToString()  ) 

            


        }





		#+++++++++++++++++++++++++++++++++++++++++++++++++
		# Section  A: Add Email Address
		#+++++++++++++++++++++++++++++++++++++++++++++++++

		1
		{

			#####################################################################
			# Set Primary email address
			#####################################################################

			# Section 1: information 

				clear-host
				write-host
				write-host
				write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                            
				write-host  -ForegroundColor white		Introduction                                                                                          
				write-host  -ForegroundColor white		--------------------------------------------------------------------------------------                                                              
				write-host  -ForegroundColor white  	'This option will: '
				write-host  -ForegroundColor white  	'Set Primary email address for a recipent'
				write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
				write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
				write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -EmailAddress “<Primary email address>”'
				write-host  -ForegroundColor white		----------------------------------------------------------------------------  	
				
					# Section 2: user input	
					
					write-host -ForegroundColor white	'User input '
					write-host -ForegroundColor white	---------------------------------------------------------------------------- 
					write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
					write-host
					write-host
					write-host
					write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
					write-host -ForegroundColor Yellow	"For example: John"
					$Mailbox  = Read-Host "Type the User Mailbox alias "
					write-host
					write-host
					write-host -ForegroundColor Yellow	"2)User Primary email address"  
					write-host -ForegroundColor Yellow	"For example: John@o365info.com"
					write-host
					$PrimAddress = Read-Host "Type the User Primary email address "
					write-host
					
					# Section 3: PowerShell Command
					Set-Mailbox $Mailbox -EmailAddress “$PrimAddress” 

					write-host
					write-host
					write-host  -ForegroundColor white		----------------------------------------------------------------------------  
					write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
					write-host  -ForegroundColor white		----------------------------------------------------------------------------
					write-host
					write-host

					Get-Mailbox $Mailbox | FT -Wrap Name, DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

					write-host
					write-host
					write-host  -ForegroundColor white		----------------------------------------------------------------------------  

			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

		}   




		2
		{


			#####################################################################
			#  Set Alias Email address 
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Set Alias email address for a recipent   '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'$Email = (Get-Mailbox <Alias>).EmailAddresses  '
			write-host  -ForegroundColor Yellow  	'$Email.add("<Alias email address>")  '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
			write-host
			write-host
			write-host

				# Section 2: user input

				write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
				write-host
				write-host
				write-host
				write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
				write-host -ForegroundColor Yellow	"For example: John"
				$Mailbox  = Read-Host "Type the User Mailbox alias "
				write-host

				write-host
				write-host -ForegroundColor Yellow	"2)User	Alias email address"  
				write-host -ForegroundColor Yellow	"For example: info@o365info.com"
				write-host
				$AliasAddress = Read-Host "Type the User Alias email address "
				write-host

					# Section 3: PowerShell Command

					$Email = Get-Mailbox $Mailbox 
					$Email.EmailAddresses +=("smtp:$AliasAddress") 
					Set-Mailbox $Mailbox  -EmailAddresses $Email.EmailAddresses 


					write-host
					write-host
					write-host  -ForegroundColor white		----------------------------------------------------------------------------  
					write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
					write-host  -ForegroundColor white		----------------------------------------------------------------------------
					write-host
					write-host

					Get-Mailbox $Mailbox | FT -Wrap Name, DisplayName, PrimarySmtpAddress, EmailAddresses   | Out-String

					write-host
					write-host
					write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}







	3
	{


			#####################################################################
			# Set Primary email address + Alias address
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Set Primary email address + Alias address for a recipent   '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -EmailAddress <Primary email address>, <Alias email address>   '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
			write-host
			
					# Section 2: user input

					write-host -ForegroundColor Yellow	"You will need to Provide 3 parameters:"  
					write-host
					write-host
					write-host
					write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
					write-host -ForegroundColor Yellow	"For example: John"
					$Mailbox  = Read-Host "Type the User Mailbox alias "
					write-host

					write-host
					write-host -ForegroundColor Yellow	"2)User Primary email address"  
					write-host -ForegroundColor Yellow	"For example: John@o365info.com"
					write-host
					$PrimAddress = Read-Host "Type the User Primary email address "
					write-host
					write-host
					write-host -ForegroundColor Yellow	"3)User 	Alias email address"  
					write-host -ForegroundColor Yellow	"For example: John@o365info.com"
					write-host
					$AliasAddress = Read-Host "Type the User Primary email address "
					write-host


						# Section 3: PowerShell Command


						Set-Mailbox $Mailbox -EmailAddress $PrimAddress, $AliasAddress


						write-host
						write-host
						write-host  -ForegroundColor white		----------------------------------------------------------------------------  
						write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
						write-host  -ForegroundColor white		----------------------------------------------------------------------------
						write-host
						write-host

						Get-Mailbox $Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

						write-host
						write-host
						write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			

			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}








	4
	{


		#####################################################################
		#Add Alias Email address - Bulk Mode
		#####################################################################

		# Section 1: information 

		clear-host

		write-host
		write-host
		write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
		write-host  -ForegroundColor white		Information                                                                                          
		write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
		write-host  -ForegroundColor white  	'This option will: '
		write-host  -ForegroundColor white  	'Add Alias Email address - Bulk Mode   '

		write-host  -ForegroundColor white		----------------------------------------------------------------------------  
		write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
		write-host  -ForegroundColor Yellow  	'$mailboxes = Get-Mailbox   '
		write-host  -ForegroundColor Yellow  	'foreach ($mailbox in $mailboxes)    '
		write-host  -ForegroundColor Yellow  	'{ '
		write-host  -ForegroundColor Yellow  	'$newaddress = $mailbox.alias + "@$DomName"    '
		write-host  -ForegroundColor Yellow  	'$mailbox.EmailAddresses += $newaddress    '
		write-host  -ForegroundColor Yellow  	'Set-Mailbox -Identity $mailbox.alias -EmailAddresses $mailbox.EmailAddresses    '
		write-host  -ForegroundColor Yellow  	'} '
		write-host
		write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
		write-host
	
		# Section 2: user input

		write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
		write-host
		write-host
		write-host
		write-host -ForegroundColor Yellow	"1)Domain name suffix"  
		write-host -ForegroundColor Yellow	"For example: o365info.com"
		$DomName  = Read-Host "Type the Domain name suffix "
		write-host



		# Section 3: PowerShell Command


		

			foreach ($mailbox in $mailboxes) 
			{
				$newaddress = $mailbox.alias + "@$DomName" 
				$mailbox.EmailAddresses += $newaddress
				Set-Mailbox -Identity $mailbox.alias -EmailAddresses $mailbox.EmailAddresses
			}
		
		
		write-host
		write-host
		write-host  -ForegroundColor white		----------------------------------------------------------------------------  
		write-host  -ForegroundColor white  	Display information about Mailboxes Email Address
		write-host  -ForegroundColor white		----------------------------------------------------------------------------
		write-host
		write-host

		Get-Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

		write-host
		write-host
		write-host  -ForegroundColor white		----------------------------------------------------------------------------  


		# Section 4: export info


		#Section 5: End the Command
		write-host
		write-host
		Read-Host "Press Enter to continue..."
		write-host
		write-host

	}







	5
	{


		#####################################################################
		# Add additional email address (alias)  to all office 365 users by using CSV File  
		#####################################################################

		# Section 1: information 

		clear-host

		write-host
		write-host
		write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
		write-host  -ForegroundColor white		Information                                                                                          
		write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
		write-host  -ForegroundColor white  	'This option will: '
		write-host  -ForegroundColor white  	'Add Alias Email address - Bulk Mode   '
		write-host  -ForegroundColor white		----------------------------------------------------------------------------  
		write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
		write-host  -ForegroundColor Yellow  	'$Users = Import-CSV "<Path>"    '
		write-host  -ForegroundColor Yellow  	'$Users | ForEach {Set-Mailbox $_.UserID -EmailAddresses   '
		write-host  -ForegroundColor Yellow  	'$_.NewAddress,$_.UserID,$_.Proxy1}   '
		write-host
		write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
		write-host
		write-host
		write-host
		write-host

		# Section 2: user input

		write-host -ForegroundColor Yellow	"You will need to Provide 1 parameter:"  
		write-host
		write-host
		write-host
		write-host -ForegroundColor Yellow	"1)CSV File path and file name"  
		write-host -ForegroundColor Yellow	"For example: C:\TEM\USERS.CSV"
		$PathFile  = Read-Host "Type the CSV File path and file name "
		write-host

		# Section 3: PowerShell Command

		$Users = Import-CSV "$PathFile" 
		$Users | ForEach {Set-Mailbox $_.UserID -EmailAddresses $_.NewAddress,$_.UserID,$_.Proxy1} 

		write-host
		write-host
		write-host  -ForegroundColor white		----------------------------------------------------------------------------  
		write-host  -ForegroundColor white  	Display information about Mailboxes Email Address
		write-host  -ForegroundColor white		----------------------------------------------------------------------------
		write-host
		write-host

		Get-Mailbox | FT -Wrap Name, DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

		write-host
		write-host
		write-host  -ForegroundColor white		----------------------------------------------------------------------------  


		#Section 5: End the Command
		write-host
		write-host
		Read-Host "Press Enter to continue..."
		write-host
		write-host

	}




	6
	{


			#####################################################################
			#   Add X.500 Email address
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Add X.500 Email address for a recipent   '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -EmailAddress “<Primary email address>”  '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
		

			# Section 2: user input

			# Section 2: user input

			write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
			write-host
			write-host
			write-host
			write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
			write-host -ForegroundColor Yellow	"For example: John"
			$Mailbox  = Read-Host "Type the User Mailbox alias "
			write-host
			write-host
			write-host -ForegroundColor Yellow	"2)X.500 email address"  
			write-host -ForegroundColor Yellow	"For example: X500:/O=ORG1 /OU=FIRST ADMINISTRATIVE GROUP/CN=RECIPIENTS/CN=07"
			write-host
			$PrimAddress = Read-Host "Type the User X.500 email address "
			write-host

			# Section 3: PowerShell Command


			Set-Mailbox $Mailbox -EmailAddress “$PrimAddress” 

			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
			write-host  -ForegroundColor white		----------------------------------------------------------------------------
			write-host
			write-host

			Get-Mailbox $Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			# Section 4: export info


			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}


	7
	{


				#####################################################################
				#   Set Primary email address
				#####################################################################

				# Section 1: information 

				clear-host

				write-host
				write-host
				write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
				write-host  -ForegroundColor white		Information                                                                                          
				write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
				write-host  -ForegroundColor white  	'This option will: '
				write-host  -ForegroundColor white  	'Set Primary email address for a Public folder   '

				write-host  -ForegroundColor white		----------------------------------------------------------------------------  
				write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
				write-host  -ForegroundColor Yellow  	'Set-MailPublicFolder  <Alias> PrimarySmtpAddress “<Primary email address>”  '
				write-host
				write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
				write-host
				write-host

			

					# Section 2: user input

					write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
					write-host
					write-host
					write-host
					write-host -ForegroundColor Yellow	"1)Public folder Mailbox alias"  
					write-host -ForegroundColor Yellow	"For example: Support"
					$Mailbox  = Read-Host "Type the Public folder Mailbox alias "
					write-host
					write-host
					write-host -ForegroundColor Yellow	"2)User Primary email address"  
					write-host -ForegroundColor Yellow	"For example: Support@o365info.com"
					write-host
					$PrimAddress = Read-Host "Type the  Primary email address "
					write-host

						# Section 3: PowerShell Command


						Set-MailPublicFolder  $Mailbox PrimarySmtpAddress $PrimAddress

						write-host
						write-host
						write-host  -ForegroundColor white		----------------------------------------------------------------------------  
						write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
						write-host  -ForegroundColor white		----------------------------------------------------------------------------
						write-host
						write-host

						Get-Mailbox $Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

						write-host
						write-host
						write-host  -ForegroundColor white		----------------------------------------------------------------------------  



				#Section 5: End the Command
				write-host
				write-host
				Read-Host "Press Enter to continue..."
				write-host
				write-host

	}




	#+++++++++++++++++++++++++++++++++++++++++++++++++
	# B: Remove Email Address
	#+++++++++++++++++++++++++++++++++++++++++++++++++


	8
	{


			#####################################################################
			#   Remove Email address (Alias)
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Remove Email address (Alias)   '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -EmailAddresses @{Remove=”<Alias email address>"}   '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
		
			# Section 2: user input

			write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
			write-host
			write-host
			write-host
			write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
			write-host -ForegroundColor Yellow	"For example: John"
			$Mailbox  = Read-Host "Type the User Mailbox alias "
			write-host
			write-host
			write-host -ForegroundColor Yellow	"2)User Alias email address"  
			write-host -ForegroundColor Yellow	"For example: John@o365info.com"
			write-host
			$AliasAddress = Read-Host "Type the User Primary email address "
			write-host

			# Section 3: PowerShell Command

			Set-Mailbox $Mailbox -EmailAddresses @{Remove=$AliasAddress} 

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
			write-host  -ForegroundColor white		----------------------------------------------------------------------------
			write-host
			write-host

			Get-Mailbox $Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			# Section 4: export info


			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}





	9
	{


			#####################################################################
			# Remove X.500 Email address
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Remove X.500 Email address   '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Set-Mailbox <Alias> -EmailAddresses @{Remove=”<X.500 email address>"}    '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
			write-host
			write-host
			write-host

			# Section 2: user input

			# Section 2: user input

			write-host -ForegroundColor Yellow	"You will need to Provide 2 parameters:"  
			write-host
			write-host
			write-host
			write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
			write-host -ForegroundColor Yellow	"For example: John"
			$Mailbox  = Read-Host "Type the User Mailbox alias "
			write-host
			write-host
			write-host -ForegroundColor Yellow	"2)User X.500 Email address"  
			write-host -ForegroundColor Yellow	"For example: X500:/O=ORG1 /OU=FIRST ADMINISTRATIVE GROUP/CN=RECIPIENTS/CN=07"
			write-host
			$X500Address = Read-Host "Type the User X.500 Email address "
			write-host

			# Section 3: PowerShell Command

			Set-Mailbox $Mailbox -EmailAddresses @{Remove=$X500Address} 



			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
			write-host  -ForegroundColor white		----------------------------------------------------------------------------
			write-host
			write-host

			Get-Mailbox $Mailbox | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			# Section 4: export info


			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}





	#+++++++++++++++++++++++++++++++++++++++++++++++++
	#C: Display/Export information about Email Address
	#+++++++++++++++++++++++++++++++++++++++++++++++++
	 


	10
	{


			#####################################################################
			#  Display Email address information on screen - Using the Wrap parameter for a Specific Mailboxes
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	'Display Email address information on screen - Using the Wrap parameter  '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Get-Mailbox <Alias>  | FT -Wrap Name, DisplayName,PrimarySmtpAddress,EmailAddresses  '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
		
			# Section 2: user input

			write-host -ForegroundColor Yellow	"You will need to Provide 1 parameters:"  
			write-host
			write-host
			write-host
			write-host -ForegroundColor Yellow	"1)User Mailbox alias"  
			write-host -ForegroundColor Yellow	"For example: John"
			$Mailbox  = Read-Host "Type the User Mailbox alias "
			write-host

			
			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	Display information about "$Mailbox".ToUpper() Email Address
			write-host  -ForegroundColor white		----------------------------------------------------------------------------
			write-host
			write-host

			Get-Mailbox $Mailbox  | FT -Wrap Name,DisplayName,PrimarySmtpAddress,EmailAddresses   | Out-String

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  


			# Section 4: export info


			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}





	11
	{


			#####################################################################
			#   Display Email address information on screen - Using the Wrap parameter all Mailboxes
			#####################################################################

			# Section 1: information 

			clear-host

			write-host
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
			write-host  -ForegroundColor white		Information                                                                                          
			write-host  -ForegroundColor white		----------------------------------------------------------------------------                                                             
			write-host  -ForegroundColor white  	'This option will: '
			write-host  -ForegroundColor white  	' Display Email address information on screen - Using the Wrap parameter all Mailboxes  '

			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	'The PowerShell command that we use is: '
			write-host  -ForegroundColor Yellow  	'Get-Mailbox  | FT -Wrap Name, DisplayName,PrimarySmtpAddress,EmailAddresses  '
			write-host
			write-host  -ForegroundColor Magenta	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                          
			write-host
		
			# Section 3: PowerShell Command

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  
			write-host  -ForegroundColor white  	 Display Email address information on screen - Using the Wrap parameter all Mailboxes
			write-host  -ForegroundColor white		----------------------------------------------------------------------------
			write-host
			write-host

			Get-Mailbox -ResultSize Unlimited |  Where {$_.name -notlike '*DiscoverySearchMailbox*'} | FT -Wrap Name, DisplayName, PrimarySmtpAddress, EmailAddresses   | Out-String

			write-host
			write-host
			write-host  -ForegroundColor white		----------------------------------------------------------------------------  



			#Section 5: End the Command
			write-host
			write-host
			Read-Host "Press Enter to continue..."
			write-host
			write-host

	}



	12
	{

			####################################################################################################
			# Export information about email address to CSV file
			######################################################################################################


			#----------------------------------------------------------
			if (!(Test-Path -path C:\INFO))
			{
			New-Item C:\INFO\ -type directory
			}


			$date = Get-Date -format "dd.mm.yyyy hh-mm-ss"

			write-host


			#----------------------------------------------------------

			###CSV####
			Get-Mailbox -ResultSize Unlimited |  Where {$_.name -notlike '*DiscoverySearchMailbox*'} | Sort Alias | Select  UserPrincipalName, DisplayName,Name,Identity, Alias,RecipientTypeDetails, EmailAddresses, PrimarySmtpAddress, 
			MicrosoftOnlineServicesID, WindowsLiveID,WindowsEmailAddress | Export-CSV c:\info\Get-Mailbox.CSV –NoTypeInformation
			##########


			#----------------------------------------------------------

			}

		 

	13
	{

			####################################################################################################
			#  Export information about email address to HTML file
			######################################################################################################


			#----------------------------------------------------------
			if (!(Test-Path -path C:\INFO))
			{
			New-Item C:\INFO\ -type directory
			}


			$htstyle = '<style>'
			$htstyle = $htstyle + “body{font-family:segoe ui,arial;color:black; }” 
			$htstyle = $htstyle + “table{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}” 
			$htstyle = $htstyle + “th{border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:#0072c6 ;color:white;}” 
			$htstyle = $htstyle + “td{border-width: 1px;padding: 5px;border-style: solid;border-color: #d1d3d4;background-color:white}” 
			$htstyle = $htstyle + “</style>” 


			$date = Get-Date -format "dd.mm.yyyy hh-mm-ss"

			write-host


			#----------------------------------------------------------



			###HTML####
			Get-Mailbox -ResultSize Unlimited |  Where {$_.name -notlike '*DiscoverySearchMailbox*'} | Sort DisplayName | select   UserPrincipalName, DisplayName, Alias,RecipientTypeDetails, EmailAddresses, PrimarySmtpAddress | ConvertTo-Html -head $htstyle -Body  "<H1>Exchange online users Mailboxes Details</H1>"  | Out-File C:\INFO\Get-Mailbox.html
			##########

			#----------------------------------------------------------



	}

  
		
						
				 
				#+++++++++++++++++++
				# Step -05 Finish  
				##++++++++++++++++++
				 
				 
				14{

				##########################################
				# Disconnect PowerShell session  
				##########################################


				write-host -ForegroundColor Yellow Choosing this option will Disconnect the current PowerShell session 

				Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
				Disconnect-ExchangeOnline -confirm

				write-host
				write-host

				#———— Indication ———————

				if ($lastexitcode -eq 0)
				{
					write-host -------------------------------------------------------------
					write-host "The command complete successfully !" -ForegroundColor Yellow
					write-host "The PowerShell session is disconnected" -ForegroundColor Yellow
					write-host -------------------------------------------------------------
				}
				else

				{
					write-host "The command Failed :-(" -ForegroundColor red
					
				}

				#———— End of Indication ———————


				}




				15{

				##########################################
				# Exit  
				##########################################


				$Loop = $true
				Exit
				}

				}


				}
