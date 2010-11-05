# Copyright (c) 2010 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# locals.
$accessKeyID = Get-NewResource access_key_id
$secretAccessKey = Get-NewResource secret_access_key

#stop and fail script when a command fails
$ErrorActionPreference="Stop"

$region = $env:EC2_PLACEMENT_AVAILABILITY_ZONE.substring(0,$env:EC2_PLACEMENT_AVAILABILITY_ZONE.length-1)

Write-Output "*** Instance is in region: [$region]"

$ec2_config = New-Object –TypeName Amazon.EC2.AmazonEC2Config 
[void]$ec2_config.WithServiceURL("https://$region.ec2.amazonaws.com")

#create ec2 client based on the ServiceURL(region)
$client_ec2=[Amazon.AWSClientFactory]::CreateAmazonEC2Client($accessKeyID,$secretAccessKey,$ec2_config)

$request = New-Object –TypeName Amazon.EC2.Model.TerminateInstancesRequest

[void]$request.WithInstanceId($env:EC2_INSTANCE_ID)

$ec2_describe_response=$client_ec2.TerminateInstances($request);

$ec2_describe_response.TerminateInstancesResult




