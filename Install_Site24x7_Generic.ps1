#Create download directory
mkdir C:\site24x7\

# Download package
Invoke-WebRequest https://staticdownloads.site24x7.eu/server/Site24x7WindowsAgent.msi -OutFile C:\site24x7\Site24x7WindowsAgent.msi

# Switch location
Set-Location C:\site24x7\

# Run installation
Start-Process -FilePath msiexec.exe -ArgumentList '/i Site24x7WindowsAgent.msi EDITA1= ENABLESILENT=YES REBOOT=ReallySuppress TP="Jisc Cloud default Server Monitor thresholds" NP="Default Notification" GN="" /qn'

#Wait a minute
Start-sleep 60

#Clean up
del Site24x7WindowsAgent.msi
