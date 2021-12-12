#!/bin/bash
echo "What is your tailscale web server host ip?"
read host
echo "What is your tailscale router ip?"
read router
echo "What is the name of your tailscale router LAN interface?"
read interface
echo "Which port do you want to forward?"
read port
sudo iptables -A FORWARD -i $interface -o tailscale0 -p tcp --syn --dport $port -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -i $interface -o tailscale0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i tailscale0 -o $interface -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i $interface -p tcp --dport $port -j DNAT --to-destination $host
sudo iptables -t nat -A POSTROUTING -o tailscale0 -p tcp --dport $port -d $host -j SNAT --to-source $router
echo "Do you want to make your changes persistent? (yes/no)"
read reply
if [ "$reply" = "yes" ]; then
  sudo service iptables-persistent save
  echo "Permanent rule set."
else 
  echo "Rule did not save."
fi