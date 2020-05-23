$zonename = 'subway.com'
$hostname = 'www'
$ipv4 = '23.192.13.236'
$updated_dsdc = 'DC1'

# Delete existing DNS entry
try {Invoke-Command -ComputerName $updated_dsdc -ScriptBlock { Remove-DnsServerResourceRecord -ZoneName $Using:zonename -Name $Using:hostname -RRType A -Force }}
catch {"No existing DNS entry" }

# Create new DNS entry
try {Invoke-Command -ComputerName $updated_dsdc -ScriptBlock { Add-DnsServerResourceRecordA -ZoneName $Using:zonename -Name $Using:hostname -IPv4Address $Using:ipv4 }}
catch {"Did not create DNS entry"}

# Connect to updated_dsdc and Sync to other DNS Servers
$dsdc_list = "DC2", "DC3", "DC4", "DC5"
Foreach ($x in $dsdc_list)
{
Invoke-Command -ComputerName $updated_dsdc -ScriptBlock { Sync-DnsServerZone -ComputerName $Using:x -Name $Using:zonename -PassThru -Verbose}
Invoke-Command -ComputerName $x -ScriptBlock { ipconfig /flushdns }
}

# Wait for 200 Seconds for replication
Start-Sleep -Seconds 200

# Flush DNS on Web Front Ends
$wfe_list = "WFE1", "WFE2", "WFE3", "WFE4"
Foreach ($y in $wfe_list)
{
Invoke-Command -ComputerName $y -ScriptBlock { ipconfig /flushdns } 
}
