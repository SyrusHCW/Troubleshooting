#!/usr/bin/python
import dns.resolver
import requests
import sys

my_resolver = dns.resolver.Resolver()


dns_name = sys.argv[1]    #DNS Name you are quering to be passed via sys arg
dns_list = ['9.9.9.9', '8.8.8.8', '1.1.1.1']   #List of DNS Servers; going to make it read in from a hosted web file

dns_name_ips = []    #list of returned IP address for requested DNS Name
dns_server_ips = []    #which DNS server was used to get returned a record

for server in range(0,len(dns_list)):
    dns.resolver.default_resolver = dns.resolver.Resolver(configure=False)
    dns.resolver.default_resolver.nameservers = [ dns_list[server] ]
    r = dns.resolver.query(dns_name, 'a')
    for x in r:
        dns_name_ips.append(str(x))
        dns_server_ips.append(dns_list[server])


working_dns_server_ip = []    #List of DNS Servers that get a 200
working_dns_name_ip = []      #List of DNS Name IP's that get a 200

# Loop through all the returned DNS Name ips, until you get a 200
for x in range(0,len(dns_name_ips)):
    request_url = '{0}{1}'.format("https://", dns_name_ips[x])
    headers = { 'host': dns_name }
    response = requests.request("GET", request_url, headers = headers, verify = False)    #since we are using IP and not DNS, SSL error will be given
    if response.status_code == 200:
        #print(True)
        working_dns_server_ip.append(dns_server_ips[x])
        working_dns_name_ip.append(dns_name_ips[x])
    else:
      continue

hostname = dns_name.split('.')                  
extract = '{0}{1}'.format(hostname[0], '.')   #extracts hostname
dns_zone = dns_name.split(extract)            #extacts zone name

array = {"hostname": hostname[0],
        "dns zone": dns_zone[1],
        "ipv4": working_dns_name_ip[0]}

print(array)
