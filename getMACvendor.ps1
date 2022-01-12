# This script will take a MAC address text file and search online for it's vendor/organization.
# Requires a MACs.txt file in the same directory as the script.
# Outputs the results to an array ($Listing) for formating or Export-CSV.

Clear-Host
$Listing = @()
If (Test-Path .\Vendors.csv) {Remove-Item .\Vendors.csv -Force}
$MACs = Get-Content .\MACs.txt
$MACs = $MACs -replace '[:]',''
$i = 0
 
Write-Host "--------------------------------"
 
Foreach ($MAC in $MACs) {
    $displayMAC = $MAC -replace '(..(?!$))','$1:'  
 
    Write-Progress -Activity "Checking MAC Addresses" -Status "Looking for $displayMAC" -PercentComplete ($i/$MACs.count*100)
   
    $URI  = "http://aruljohn.com/mac/$MAC"
    $HTML = Invoke-WebRequest -Uri $URI
    Try {
            $org = (($HTML.ParsedHtml.getElementsByTagName("td")) | Select-Object innerText)[1].innerText
        }
    Catch { Write-Host "$displayMAC is not listed or is incorrect."
            $Object = New-Object -TypeName psobject
            $Object | Add-Member -MemberType NoteProperty -Name MAC -Value $displayMAC
            $Object | Add-Member -MemberType NoteProperty -Name Organization -Value $null
            $Listing += $object
            Continue
        }
 
    $Object = New-Object -TypeName psobject
    $Object | Add-Member -MemberType NoteProperty -Name MAC -Value $displayMAC
    $Object | Add-Member -MemberType NoteProperty -Name Organization -Value $org
 
    $Listing += $object
    $i++
  }
 
Write-Host "--------------------------------"
 
$Listing | Export-CSV -Path .\Vendors.csv -NoTypeInformation -Delimiter ","
 
$Listing
