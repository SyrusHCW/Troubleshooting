$zonename = $args[0]
$hostname = $args[1]
$ipv4 = $args[2]

Invoke-Command -ComputerName DSDC1 -ScriptBlock { Add-DnsServerResourceRecordA -ZoneName $zonename -Name $hostname -IPv4Address $ipv4 }

$dsdc_list = "DSDC2", "DSDC3", "DSDC4"
Foreach ($x in $dsdc_list)
{
Invoke-Command -ComputerName $x -ScriptBlock { dnscmd DSDC1 /zonerefresh $zonename } 
}

$wfe_list = "wfe1", "wfe2"
Foreach ($y in $wfe_list)
{
Invoke-Command -ComputerName $y -ScriptBlock { ipconfig /flushdns } 
} 
