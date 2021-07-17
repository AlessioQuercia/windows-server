# WindowsHomeServer
Setup Windows computer as a Server.

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

## 2 - Setup the Server
Do this step in the computer you want to setup as a Server.

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

## 3 - Setup the Client
Do this step in every local computer you want to use to connect to the Server.

## 3.1 - Install wolcmd and add it to your PATH
Download and install [wolcmd](https://www.depicus.com/wake-on-lan/wake-on-lan-cmd). 

Once installed, add the wolcmd installation folder to your PATH variables:
Go to **Start** --> Type in **env** and select **Edit the system environment variables** --> Click on **Environment variables** --> Click on the **Path** in the **System Variables** --> Click on **Modify** --> Click on **Add new** and type your wolcmd installation folder --> Click on **Ok**.

## Wake up the Server
```
wolcmd [MAC address] [IP address] [Subnet mask] [Port number]
```
where MAC address, IP address and Subnet mask are the ones retrieved in Step 2.2 from the Server. The default Port number is 7.

## Connect to the Server
```
ssh username@servername
```
where username is the user's name of the account you want to connect to in the Server, and servername is the Server ipv4 address. If the selected Server account has a password, it will be asked.

## Hibernate the Server
Run the following command to hibernate the Server. By doing so, you will be able to wake it again using wolcmd.
```
shutdown /h
```
