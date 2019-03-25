#Retrieve all mailboxes in the Exchange organization 
$mailboxes = Get-Mailbox -ResultSize unlimited 
 
#Output file
$OutputFile = "C:\CSV\ActiveSyncUsers.csv"

#Setup headers
Out-File -FilePath $OutputFile -InputObject "DisplayName,UPN,Status,DeviceID,DeviceEnableOutboundSMS,DeviceMobileOperator,DeviceAccessState,DeviceAccessStateReason,DeviceAccessControlRule,DeviceType,DeviceUserAgent,DeviceModel,DeviceFriendlyName,DeviceOS,DeviceOSLanguage,IsRemoteWipeSupported,DeviceWipeSentTime,DeviceWipeRequestTime,DeviceWipeAckTime,LastDeviceWipeRequestor,DevicePolicyApplied,DevicePolicyApplicationStatus,DeviceActiveSyncVersion ,FirstSyncTime,LastPolicyUpdateTime,LastSyncAttemptTime,LastSuccessSync,NumberOfFoldersSynced" -Encoding UTF8
 
#Loop through each mailbox 
foreach ($mailbox in $mailboxes) { 
	$devices = Get-ActiveSyncDeviceStatistics -Mailbox $mailbox.samaccountname 
	 
	#If the current mailbox has an ActiveSync device associated, loop through each device 
	if ($devices) { 
		foreach ($device in $devices){ 
		  
			#Create a new object and add custom note properties for each device.  Comment out the ones you don't need
			$deviceobj = New-Object -TypeName psobject 
			$deviceobj | Add-Member -Name DisplayName -Value $mailbox.DisplayName -MemberType NoteProperty 
			$deviceobj | Add-Member -Name UPN -Value $mailbox.UserPrincipalName -MemberType NoteProperty 
			$deviceobj | Add-Member -Name Status -Value $device.Status -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceID -Value $device.DeviceID -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceEnableOutboundSMS -Value $device.DeviceEnableOutboundSMS -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceMobileOperator -Value $device.DeviceMobileOperator -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceAccessState -Value $device.DeviceAccessState -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceAccessStateReason -Value $device.DeviceAccessStateReason -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceAccessControlRule -Value $device.DeviceAccessControlRule -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceType -Value $device.DeviceType -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceUserAgent -Value $device.DeviceUserAgent -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceModel -Value $device.DeviceModel -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceFriendlyName -Value $device.DeviceFriendlyName -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceOS -Value $device.DeviceOS -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceOSLanguage -Value $device.DeviceOSLanguage -MemberType NoteProperty 
			$deviceobj | Add-Member -Name IsRemoteWipeSupported -Value $device.IsRemoteWipeSupported -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceWipeSentTime -Value $device.DeviceWipeSentTime -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceWipeRequestTime -Value $device.DeviceWipeRequestTime -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceWipeAckTime -Value $device.DeviceWipeAckTime -MemberType NoteProperty 
			$deviceobj | Add-Member -Name LastDeviceWipeRequestor -Value $device.LastDeviceWipeRequestor -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DevicePolicyApplied -Value $device.DevicePolicyApplied -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DevicePolicyApplicationStatus -Value $device.DevicePolicyApplicationStatus -MemberType NoteProperty 
			$deviceobj | Add-Member -Name DeviceActiveSyncVersion -Value $device.DeviceActiveSyncVersion -MemberType NoteProperty 
			$deviceobj | Add-Member -Name FirstSyncTime -Value ($device.FirstSyncTime).ToString("yyyy-MM-dd HH:mm:ss") -MemberType NoteProperty 
			$deviceobj | Add-Member -Name LastPolicyUpdateTime -Value ($device.LastPolicyUpdateTime).ToString("yyyy-MM-dd HH:mm:ss") -MemberType NoteProperty 
			$deviceobj | Add-Member -Name LastSyncAttemptTime -Value ($device.LastSyncAttemptTime).ToString("yyyy-MM-dd HH:mm:ss") -MemberType NoteProperty 
			$deviceobj | Add-Member -Name LastSuccessSync -Value ($device.LastSuccessSync).ToString("yyyy-MM-dd HH:mm:ss") -MemberType NoteProperty 
			$deviceobj | Add-Member -Name NumberOfFoldersSynced -Value $device.NumberOfFoldersSynced -MemberType NoteProperty 
			
			#Write the custom object to the pipeline 
			Write-Output -InputObject $deviceobj 
			
			#Write line to file
			Out-File -FilePath $OutputFile -InputObject "$($deviceobj.DisplayName),$($deviceobj.UPN),$($deviceobj.Status),$($deviceobj.DeviceID),$($deviceobj.DeviceEnableOutboundSMS),$($deviceobj.DeviceMobileOperator),$($deviceobj.DeviceAccessState),$($deviceobj.DeviceAccessStateReason),$($deviceobj.DeviceAccessControlRule),$($deviceobj.DeviceType),$($deviceobj.DeviceUserAgent),$($deviceobj.DeviceModel),$($deviceobj.DeviceFriendlyName),$($deviceobj.DeviceOS),$($deviceobj.DeviceOSLanguage),$($deviceobj.IsRemoteWipeSupported),$($deviceobj.DeviceWipeSentTime),$($deviceobj.DeviceWipeRequestTime),$($deviceobj.DeviceWipeAckTime),$($deviceobj.LastDeviceWipeRequestor),$($deviceobj.DevicePolicyApplied),$($deviceobj.DevicePolicyApplicationStatus),$($deviceobj.DeviceActiveSyncVersion),$($deviceobj.FirstSyncTime),$($deviceobj.LastPolicyUpdateTime),$($deviceobj.LastSyncAttemptTime),$($deviceobj.LastSuccessSync),$($deviceobj.NumberOfFoldersSynced)" -Encoding UTF8 -append
			
		} 
	 
	} 
 
}