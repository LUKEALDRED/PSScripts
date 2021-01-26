# Sets the correct profile for running the below commands
Set-AWSCredential -ProfileName <PROFILE NAME>

# Creates an empty array ready to receive a list of EC2 instance ids
$instanceList = [System.Collections.ArrayList]::new()

# Gets EC2 instances on Windows that are currently in the running state
# Updates the array which holds all the instance ids for use further down the script
# Creats an AMI of each instance
(Get-EC2Instance -Filter @{Name="instance-state-name";Values="running"},@{Name="platform";Values="windows"}).Instances | ForEach-Object { [void]$instanceList.Add($_.InstanceId); $name=$_.InstanceId + '-pre-site24x7'; $description='Image of ' + $_.InstanceId + ' before installing Site24x7'; New-EC2Image -InstanceId $instance.InstanceId -Name $name -Description $description -NoReboot $true }

# Stores the PowerShell commands, that will be passed to the SSM command, for installing Site24x7, in a variable called $commands
$commands = "mkdir C:\site24x7\; Invoke-WebRequest https://staticdownloads.site24x7.eu/server/Site24x7WindowsAgent.msi -OutFile C:\site24x7\Site24x7WindowsAgent.msi; Set-Location C:\site24x7\; Start-Process -FilePath msiexec.exe -ArgumentList '/i Site24x7WindowsAgent.msi EDITA1=<DEVICE KEY> ENABLESILENT=YES REBOOT=ReallySuppress TP=""Jisc Cloud default Server Monitor thresholds"" NP=""Default Notification"" GN=""<GROUP NAME>"" /qn'; ping -n 60 127.0.0.1 > wait.txt; del Site24x7WindowsAgent.msi; del wait.txt;"

# Runs the above PowerShell commands on the instances in the array
Send-SSMCommand -InstanceId $instanceList -DocumentName "AWS-RunPowerShellScript" -Parameter @{commands = $commands }