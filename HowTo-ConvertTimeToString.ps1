#How to convert current date and time for naming a text file

Export-csv C:\CSV\FileName-$([DateTime]::Now.ToString("MM-dd-yyyy-hh.mm.ss")).csv"