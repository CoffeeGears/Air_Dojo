#!/bin/bash                                                                     
#dmasqaccesspoint                                                               
#networksetup                                                                   
                                                                                
sudo apt-get install dnsmasq                                                    
                                                                                
cat dmasqaccesspoint > /etc/dnsmasq.d/access_point.conf                        
cat interfaces > /etc/network/interfaces                                        
                                                                                
sudo ifup wlan1                                                                 
ip addr show wlan1                                                              
sudo /etc/init.d/dnsmasq restart                                                
cat hostapd > /etc/hostapd.conf                                                 
                                                                                
sudo hostapd /etc/hostapd.conf                                                  
cat service > /lib/systemd/system/hostapd-systemd.service                       
sudo update-rc.d hostapd disable                                                
sudo systemctl daemon-reload                                                    
sudo systemctl enable hostapd-systemd                                           
sudo systemctl start hostapd-systemd                                            
systemctl status hostapd-systemd   
