<#

Install AWS tools, login to AWS, manipulate S3 buckets, invoke a Lambda function, capture the return body.

#>

# First, set current region and profile so you don't have to specify them in each cmdlet

Set-DefaultAWSRegion -Region ap-southeast-2 
Set-AWSCredential -ProfileName my-sso-profile 

Get-AWSRegion

# https://docs.aws.amazon.com/powershell/latest/userguide/creds-idc.html#idc-config-sdk

$params = @{
  ProfileName = 'my-sso-profile'
  AccountId = '369672185060'
  RoleName = 'PowerUserAccess'
  SessionName = 'my-sso-session'
  StartUrl = 'https://d-9767b527ac.awsapps.com/start'
  SSORegion = 'ap-southeast-2'
  RegistrationScopes = 'sso:account:access' # what other values might help here?
};
# Initialize-AWSSSOConfiguration @params
# this gets a successful authentication but then says the AccountId is invalid

# New-AWSCredential -ProfileName 'my-sso-profile'


<#
Invoke-AWSSSOLogin -ProfileName 'my-sso-profile' -Force
Install-AWSToolsModule AWS.Tools.Lambda -Force
Install-AWSToolsModule AWS.Tools.Common -Force
#>

Get-InstalledModule -Name AWS.Tools.* | Format-Table

Get-STSCallerIdentity -ProfileName my-sso-profile -Region ap-southeast-2 

Invoke-AWSSSOLogin -ProfileName my-sso-profile
# this invokes Access Portal signon in browser, where I authenticate as user "pl32983" with password & fingerprint MFA. 
# New session can be confirmed via IAM Identity Center console.


# create an S3 bucket
$bucket = New-S3Bucket -BucketName 'hantha2-hello-world-bucket'
# This worked, but only after group & permissionSet were set up correctly in AWS Identity Center & S3
$bucket.BucketName

# upload a local file to the new bucket
Write-S3Object -BucketName $bucket.BucketName -File C:\Users\674pe\Downloads\Transactions.csv -Key ABC123

Get-AWSCredential -ListProfileDetail 

# list all Lambda functions, their associated roles etc
Get-LMFunctionList

# Example request payload
$jsonPayload = @{
    key1 = "value1"
    key2 = "value2"
} | ConvertTo-Json -Depth 10

# Invoke a Lambda function & display the response payload body
$response = Invoke-LMFunction PythonHelloWorld
$reader = [System.IO.StreamReader]::new($response.Payload)
$d = $reader.ReadToEnd() | ConvertFrom-Json
$d.body

#--------------- CLEAN UP ------------------------------

Remove-S3Object -BucketName $bucket.BucketName -Key ABC123
Remove-S3Bucket -BucketName 'hantha2-hello-world-bucket'

Invoke-AWSSSOLogout
# this works - session ends (also confirmed from IAM Identity Center console)
