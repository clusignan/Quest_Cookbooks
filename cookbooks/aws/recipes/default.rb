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

powershell "Install AWS SDK" do
  attachments_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files', 'install_dotnet_sdk'))
  providers_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'powershell_providers'))
  parameters({'ATTACHMENTS_PATH' => attachments_path,
              'PROVIDERS_PATH' => providers_path})

  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
    $aws_sdk = "AWS SDK for .NET"

    #check to see if the package is already installed
    if (Test-Path (${env:programfiles(x86)}+"\"+$aws_sdk)) { 
      $aws_sdk_path = ${env:programfiles(x86)}+"\"+$aws_sdk 
    } Elseif (Test-Path (${env:programfiles}+"\"+$aws_sdk)) { 
      $aws_sdk_path = ${env:programfiles}+"\"+$aws_sdk 
    }
    
    if ($aws_sdk_path -ne $null) {
      Write-Output "*** AWS SDK for .NET already installed in [$aws_sdk_path]. Skipping installation."
    }
    Else {
      cd "$env:ATTACHMENTS_PATH"
      Write-Output "*** Installing AWS SDK for .NET msi"
      cmd /c msiexec /package AWSSDKForNET_1.0.11.msi /quiet
      
      $rightLinkLibAwsPath = join-path (Split-Path ${env:RS_MONITORS_DIR} -parent) "aws"
      if (test-path $rightLinkLibAwsPath -PathType Container)
      {
        Write-Output "***AWS tools already installed in $rightLinkLibAwsPath"
      }
      else
      {
        mkdir $rightLinkLibAwsPath > $null
        Write-Output "***Copy AWS tools in $rightLinkLibAwsPath"
        Copy-Item -path "${env:PROVIDERS_PATH}\*" -destination "$rightLinkLibAwsPath" -recurse
      }
    }
POWERSHELL_SCRIPT

  source(powershell_script)
end