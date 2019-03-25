import-module ntfssecurity

#$rh = read-host "Enter Parent Directory"

#cd $rh

$name = get-childitem -attributes directory -s 

ForEach($directory in $name) {

Enable-NFTSAccessInheritance -Path $directory.name

}