# Specify the profile name
Set-AWSCredential -ProfileName WEG-NONLIVE-Admin

# Create the empty array of instance ids
$instanceIdArray = [System.Collections.ArrayList]::new()

# For testing $instanceIdArray = $null

# Create list of instance ids
while ($instanceId -ne "no" ) {
    $instanceId = Read-Host -Prompt 'Enter an instance id, to end enter no'
    if ($instanceId -ne "no") {
        [void]$instanceIdArray.Add($instanceId)
        }
    }

$instanceId = $null

$instanceType = Read-Host -Prompt 'Please enter an instance type'

# For each instance id store the instance as an object
$instanceIdArray | ForEach-Object {
    $currentInstance = (Get-EC2Instance -InstanceId $_).Instances
    
    # Stop the instance
    $message = 'Stopping ' + $currentInstance.instanceId
    echo $message
    Stop-EC2Instance -InstanceId $currentInstance.instanceId > $null

    # Get the state of the current instance
    $currentInstanceState = $currentInstance.State

    # While the instance is not yet stopped, loop
    while ($currentInstanceState.Name.Value -ne "stopped") {
        $message = 'Waiting for ' + $currentInstance.instanceId + ' to stop.'
        echo $message
        ping localhost -n 5 > $null
        $currentInstance = (Get-EC2Instance -InstanceId $currentInstance.instanceId).Instances
        $currentInstanceState = $currentInstance.State
        }

    # After the instance has stopped, if the instance is stopped change the instance type
    if ($currentInstanceState.Name.Value -eq "stopped") {
        $message = 'Changing instance type for ' + $currentInstance.instanceId
        echo $message
        Edit-EC2InstanceAttribute -InstanceId $currentInstance.instanceId -InstanceType $instanceType
        }

    # Start the instance
    $message = 'Starting ' + $currentInstance.instanceId
    echo $message
    Start-EC2Instance -InstanceId $currentInstance.instanceId > $null

    # While the instance is not yet running, loop
    while ($currentInstanceState.Name.Value -ne "running") {
        $message = 'Waiting for ' + $currentInstance.instanceId + ' to start.'
        echo $message
        ping localhost -n 5 > $null
        $currentInstance = (Get-EC2Instance -InstanceId $currentInstance.instanceId).Instances
        $currentInstanceState = $currentInstance.State
        }

    # Complete
    echo "Complete."
    }