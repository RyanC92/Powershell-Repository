

&lt;#
.Synopsis
    Retrieves the Computer's geographical location
.DESCRIPTION
   Retrieves the Computer Geolocation using the Windows location platform and Google geocoding API
.EXAMPLE
   Get-ComputerGeolocation
.NOTES
    Version 1.0
    Written by Alex Verboon
 
#&gt;
 
 
 
function Get-ComputerGeoLocation ()
{
 
# Windows Location API
$mylocation = new-object –ComObject LocationDisp.LatLongReportFactory
 
# Get Status 
$mylocationstatus = $mylocation.status
If ($mylocationstatus -eq "4")
{
    # Windows Location Status returns 4, so we're "Running"
 
    # Get Latitude and Longitude from LatlongReport property
    $latitude = $mylocation.LatLongReport.Latitude 
    $longitude = $mylocation.LatLongReport.Longitude
 
    if ($latitude -ne $null -or $longitude -ne $Null)
    {
        # Retrieve Geolocation from Google Geocoding API
        $webClient = New-Object System.Net.WebClient 
        Write-host "Retrieving geolocation for" $($latitude) $($longitude)
        $url = "https://maps.googleapis.com/maps/api/geocode/xml?latlng=$latitude,$longitude&amp;sensor=true"
        $locationinfo = $webClient.DownloadString($url) 
 
        $doc = $locationinfo
        # Verify the response
        if ($doc.GeocodeResponse.status -eq "OK")
        {
            $street_address = $doc.GeocodeResponse.result | Select-Object -Property formatted_address, Type | Where-Object -Property Type -eq "street_address" 
            $geoobject = New-Object -TypeName PSObject
            $geoobject | Add-Member -MemberType NoteProperty -Name Address -Value $street_address.formatted_address
            $geoobject | Add-Member -MemberType NoteProperty -Name latitude -Value $mylocation.LatLongReport.Latitude
            $geoobject | Add-Member -MemberType NoteProperty -Name longitude -Value $mylocation.LatLongReport.longitude
            $geoobject | format-list
        }
        Else
        {
            Write-Warning "Request failed, unable to retrieve Geo locatiion information from Geocoding API"  
        }
    }
    Else
        {
            write-warning "Latitude or Longitude data missing"
        }
    }
 
Else
{
    switch($mylocationstatus)
    {
    # All possible status property values as defined here: 
    # http://msdn.microsoft.com/en-us/library/windows/desktop/dd317716(v=vs.85).aspx
    0 {$mylocationstatuserr = "Report not supported"} 
    1 {$mylocationstatuserr = "Error"}
    2 {$mylocationstatuserr = "Access denied"} 
    3 {$mylocationstatuserr = "Initializing" } 
    4 {$mylocationstatuserr = "Running"} 
    }
 
    If ($mylocationstatus -eq "3")
        {
        write-host "Windows Loction platform is $mylocationstatuserr" 
        sleep 5
        Get-ComputerGeoLocation
        }
    Else
        {
        write-warning "Windows Loction platform: Status:$mylocationstatuserr"
        }
}
} # end function
Get-ComputerGeoLocation