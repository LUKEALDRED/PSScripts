#######################################################################
#                                                                     #
# This script will query the run commands that ran today and display  #
# the results                                                         #
#                                                                     #
# Written by Luke Aldred                                              #
# 15/01/2021                                                          #
# v1                                                                  #
#                                                                     #
#######################################################################

# List all profiles used to access SSM and EC2 data in AWS accounts
$SNPatchingChangeAWSProfiles = Get-AWSCredential -ProfileLocation "C:\Users\Luke.Aldred\.aws\SNPatchingChangeCredentials" -ListProfileDetail | Where-Object { $_.ProfileName -like 'SN_*' } | Select-Object -Property ProfileName

# Loop through each AWS customer using the profiles to obtain information from each customer
foreach ($profile in $SNPatchingChangeAWSProfiles) {
    Set-AWSCredential -ProfileLocation "C:\Users\Luke.Aldred\.aws\SNPatchingChangeCredentials" -ProfileName $profile.ProfileName

    # Commands runs on default region which for me is Dublin (eu-west-1) Get-DefaultAWSRegion
    foreach ($rc in Get-SSMCommand -Filter @{Key="InvokedAfter";Value=(Get-Date -Format "yyyy-MM-ddT00:00:00Z")}) { Get-SSMCommandInvocation -CommandId $rc.CommandId | Select-Object -Property CommandId,InstanceId,InstanceName,RequestedDateTime,Status | Format-Table -AutoSize }
    # Same command for London (eu-west-2)
    foreach ($rc in Get-SSMCommand -Filter @{Key="InvokedAfter";Value=(Get-Date -Format "yyyy-MM-ddT00:00:00Z")} -Region eu-west-2 ) { Get-SSMCommandInvocation -CommandId $rc.CommandId -Region eu-west-2 | Select-Object -Property CommandId,InstanceId,InstanceName,RequestedDateTime,Status | Format-Table -AutoSize }
}