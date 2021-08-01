# Guide to setup Windows as a Server

### Guide
1. [Setup SSH on Windows](#ssh)
2. [Setup the Server](#server)
3. [Setup the Client](#client)
4. [Setup the Modem](#modem)

### Commands and script
- [Wake up the Server](#wake)
- [Access the Server](#access)
- [Hibernate the Server](#hibernate)
- [Server script](#script)

### [References](#ref)


<a name="ssh"></a>
## 1 - Setup SSH on Windows
Repeat this step in the computer you want to setup as a Server and in every local computer you want to use to connect to the Server.

### 1.1 - Activate Windows Subsystem for Linux (WSL)
Go to **Start** --> **Settings** --> **Apps** --> **Programs and Features** --> **Turn Windows features on or off** --> Check **Windows Subsystem for Linux** --> Press **Ok** and then **Restart now** to restart the computer and apply the changes.

### 1.2 - Install Ubuntu (or another Linux distribution)
Go to **Start** --> Type **Microsoft Store** --> Search and install ***Ubuntu*** (or another Linux distribution) --> Once installed, launch it and follow the instruction to set it up.

### 1.3 - Install OpenSSH Client and OpenSSH Server
Right click on **Start** --> Run **Windows PowerShell as Administrator** --> Run the following commands:
```
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
```
# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the firewall rule is configured. It should be created automatically by setup.
Get-NetFirewallRule -Name *ssh*

# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
# If the firewall does not exist, create one
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

<a name="server"></a>
## 2 - Setup the Server
Do this step in the computer you want to setup as a Server. Please note that during this guide I used a computer with Windows 10 - Home edition - Build 19042 (20H2).

### 2.1 - Get the list of users
Go to **Start** --> Type and open **cmd.exe** --> Type **net user** on the Command Prompt --> Choose the account you want to connect to and remember the username.

### 2.2 - Get the Server IP address, MAC address and Subnet mask
Go to **Start** --> Type and open **cmd.exe** --> Type **ipconfig /all** on the Command Prompt --> Look under **Network Adapter**:
- The Server IP address is **IPv4 Address**.
- The Server MAC address is **Physical Address**.
- The Server Subnet mask is **Submet mask**.

### 2.3 - Setup Wake on Lan
Wake on Lan (WOL) needs to be activated in order to wake the Server from sleep/hibernate. WOL is not supported in every network adapter and BIOS, therefore there is a chance that you cannot directly use this option.

Go to **Start** --> **Settings** --> **Network and Internet** --> **Ethernet** --> **Change adapter options** --> Right click on the Ethernet connection --> Open **Properties** --> Press **Configure** --> Then:
- Go to **Power Management** tab --> Check all the three boxes --> Press **Ok**.
- Go to **Advanced** tab --> Select and enable **Wake on Magic Packet** --> Press **Ok**.

**Restart** your Server computer --> Access the **BIOS** --> Look for **APM Configuration** --> Select and enable **Power On By PCI-E**. 

Note that every BIOS is different, therefore the Wake on Lan option could be found under different names or, in the worst case, could be unavailable.

<a name="client"></a>
## 3 - Setup the Client
Do this step in every local computer you want to use to connect to the Server. During this guide I used a computer with Windows 10 - Home edition - Build 19043 (21H1).

## 3.1 - Install wolcmd and add it to your PATH
Download and install [wolcmd](https://www.depicus.com/wake-on-lan/wake-on-lan-cmd). 

Once installed, add the wolcmd installation folder to your PATH variables:
Go to **Start** --> Type in **env** and select **Edit the system environment variables** --> Click on **Environment variables** --> Click on the **Path** in the **System Variables** --> Click on **Modify** --> Click on **Add new** and type your wolcmd installation folder --> Click on **Ok**.

<a name="modem"></a>
## 4 - Setup the Modem
If you only want to access your Server from your local network (e.g. from your home), then you can skip this step. On the other hand, if you want to be able to access the Server from any remote place, procede with the following steps.

The general steps are the following ones:
- Enable Dynamic DNS (DynDNS) to be able to reach the server from outside the local network (remote network).
- Add a TCP/UDP port forwarding rule for port **7** or **9** (or for the range **7:9**), depending on which port you are using in the wolcmd command.
- Assign a static ip to your Server computer (manually from the server computer or from the Modem settings).

Depending on the modem, the home page amd settings will be different. This guide will use TIM HUB modem, but the steps are similar for other modems. The following steps show how to setup TIM HUB modem.

### 4.1 - Enable Dynamic DNS
Create your own dynamic host domain ([no-ip](https://www.noip.com/it-IT) and [Duck DNS](https://www.duckdns.org/) are two valid free options).

Once you have created and setup your dynamic host domain, follow these steps:
Open your browser --> Search "192.168.1.1" --> Access the Modem (the default username and password are both **admin**) --> Click on **WAN Services** --> Enable **DynDNS** and then:
- Service Name: your dynamic host service name (e.g. no-ip.com or duckdns.org).
- HTTPS: **Enabled**.
- Domain: your dynamic DNS domain.
- Username: your dynamic DNS username.
- Password: your dynamic DNS password.

### 4.2 - Add Port Forwarding rules
Open your browser --> Search "192.168.1.1" --> Access the Modem (the default username and password are both **admin**) --> Click on **WAN Services** --> Then:
- Click on "Add new IPv4 port mapping" and fill with the following information:
  - Name: **Wake Server** (or any other name).
  - Protocol: select **TCP/UDP**.
  - WAN port: **7:9** (to enable the ports 7,8 and 9).
  - LAN port: **7:9**.
  - Destination IP: **Server IPv4 Address**.
- Click on "Add new IPv4 port mapping" and fill with the following information:
  - Name: **SSH Server** (or any other name).
  - Protocol: select **TCP**.
  - WAN port: **22**.
  - LAN port: **22**.
  - Destination IP: **Server IPv4 Address**.

### 4.3 - Assign a static ip to your Server
Open your browser --> Search "192.168.1.1" --> Access the Modem (the default username and password are both **admin**) --> Click on **Local Network** --> Click on "Add new static lease" and then:
- Hostname: you can choose any name.
- MAC address: select **Server MAC Address**.
- IP: you can choose any IP address (even the Server IPv4 Address).

<a name="wake"></a>
## Wake up the Server
```
wolcmd [MAC address] [IP address] [Subnet mask] [Port number]
```
where MAC address, IP address and Subnet mask are the ones retrieved in Step 2.2 from the Server. The default Port number is 7, but 9 is often used as well. To broadcast the Magick Packet to the whole subnet, use 255.255.255.255 as Subnet mask (for me it is the only way of waking up the Server from a remote network, unfortunately).

<a name="access"></a>
## Access the Server
```
ssh username@servername
```
where username is the user's name of the account you want to connect to in the Server, and servername is the Server ipv4 address. If the selected Server account has a password, it will be asked.

<a name="hibernate"></a>
## Hibernate the Server
Connect to the Server using ssh and use the following command to hibernate it:
```
shutdown /h
```
By hibernating the Server, you will be able to wake it up again using wolcmd.

<a name="script"></a>
## Server Script
The script **server.bat** automates the three commands listed above (wake up, access, hibernate the Server). Note that you still need to follow the guide steps in order to setup your client, server, and modem.

In order to use the script as it is, you need to setup three environment variables: SERVER_USERNAME, SERVER_IP_ADDRESS, SERVER_MAC_ADDRESS. You can manually set them or use the three specific _server_ options: /set_usr, /set_ip, /set_mac. If you don't want to use environment variables, you can directly insert your server information inside the script.

```
Usage:

  server [Options]

Options:

  /on                     Turn the Server on.
  /off                    Turn the Server off.
  /access                 Access the Server.
  /set_usr [username]     Set an environment variable with the Server username you want to connect to.
  /set_ip [ip_address]    Set an environment variable with the Server IP address.
  /set_mac [mac_address]  Set an environment variable with the Server MAC address.

Note: Before using the on, off, access Options, you need to set the following environment variables (either manually or using the /set options):
      - SERVER_USERNAME      Username of the account you want to connect in the Server.
      - SERVER_IP_ADDRESS    IP address of the Server.
      - SERVER_MAC_ADDRESS   MAC address of the Server.
  If you don't want to use environment variables, you can manually insert the required Server information in this script.
```

Add **server.bat** script to your PATH environment variable if you want to be able to call _server_ command from anywhere with your Command Prompt.

<a name="ref"></a>
## References
- https://docs.microsoft.com/it-it/windows-server/administration/openssh/openssh_install_firstuse
- https://www.youtube.com/watch?v=MVqYKzrFrDk
- https://turbolab.it/controllo-remoto-270/grande-guida-wake-on-lan-wol-come-accendere-pc-windows-linux-ubuntu-lontano-usando-smartphone-android-connessione-internet-951
- https://turbolab.it/reti-1448/guida-come-aprire-porte-tcp-udp-router-tim-fibra-tim-hub-torrent-emule-desktop-remoto-...-2416
