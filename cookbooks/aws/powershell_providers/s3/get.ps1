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

Param($ACCESSKEYID,$SECRETACCESSKEY,$S3FILE,$S3BUCKET,$DOWNLOADDIR)

#stop and fail script when a command fails
$ErrorActionPreference="Stop"

#check to see if this powershell script was called from a Chef recipe
if (get-command Get-NewResource -ErrorAction SilentlyContinue)
{
	$accessKeyID = Get-NewResource access_key_id
	$secretAccessKey = Get-NewResource secret_access_key
	$s3Bucket = Get-NewResource s3_bucket
	$s3File = Get-NewResource s3_file
	$downloadDir = Get-NewResource download_dir
    #check the required provider parameters
	if ($accessKeyID -eq $null -or $secretAccessKey -eq $null -or $s3Bucket -eq $null -or $s3File -eq $null -or $downloadDir -eq $null){ 
		throw("Required parmeters are missing. Please provide: access_key_id, secret_access_key, s3_bucket, s3_file and download_dir")
	}
}
else
{
	#check the required script parameters
	if ($accessKeyID -eq $null -or $secretAccessKey -eq $null -or $s3Bucket -eq $null -or $s3File -eq $null -or $downloadDir -eq $null){ 
		throw("Required parameters are missing`nUSAGE: {0} -ACCESSKEYID id -SECRETACCESSKEY key -S3FILE file -S3BUCKET bucket -DOWNLOADDIR dir`n" -f $myinvocation.mycommand.name)
	}
}

$client=[Amazon.AWSClientFactory]::CreateAmazonS3Client($accessKeyID,$secretAccessKey)

$targetpath = join-path ($downloadDir) $s3File

if ($targetpath -match '^(.+)\\')
{
	$fullpath=$matches[1]
	if (!(test-path $fullpath -PathType Container))
	{
		Write-output "***Directory [$fullpath] missing, creating it."
		New-Item $fullpath -type directory > $null
	}
}

Write-output "***Downloading key[$s3File] from bucket[$s3Bucket] to [$targetpath]"
$get_request = New-Object -TypeName Amazon.S3.Model.GetObjectRequest
$get_request.BucketName = $s3Bucket
$get_request.key = $s3File

$S3Response = $client.GetObject($get_request) #NOTE: download defaults to ... minute timeout. 
#If download fails it will throw an exception and $S3Response will be $null 
if($S3Response -eq $null){ 
 Write-Error "***ERROR: Amazon S3 get requrest failed. Script halted." 
 exit 1 
} 

$responsestream=$S3Response.ResponseStream

# create the target file on the local system and the download buffer
$targetfile = New-Object IO.FileStream ($targetpath,[IO.FileMode]::Create)
[byte[]]$readbuffer = New-Object byte[] 1024

# loop through the download stream and send the data to the target file
do{
    $readlength = $responsestream.Read($readbuffer,0,1024)
    $targetfile.Write($readbuffer,0,$readlength)
}
while ($readlength -ne 0)

$targetfile.close()
