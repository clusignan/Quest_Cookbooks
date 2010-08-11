# Cookbook Name:: app_iis
# Recipe:: update_code_s3
#
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

# download the sql dump
aws_s3 "Download code from S3 bucket" do
  access_key_id @node[:aws][:access_key_id]
  secret_access_key @node[:aws][:secret_access_key]
  s3_bucket @node[:s3][:application_code_bucket]
  s3_file @node[:s3][:application_code_package]
  download_dir "c:/tmp"
  action :get
end


# Unzip code in c:\inetpub\releases
code_checkout_zip "Unzipping code in the releases directory" do
  releases_path "c:/inetpub/releases"
  zip_path "c:/tmp/"+@node[:s3][:application_code_package]
  action :unzip
end


powershell "Change IIS physical path for Default Website" do
  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
  $releasesunzippath=invoke-expression 'Get-ChefNode releasesunzippath'
  
  if (Test-Path $releasesunzippath -PathType Container)
  {
  
      # change the physicalPath for the IIS site
      $appcmd_path = $env:systemroot + "\\system32\\inetsrv\\APPCMD.exe"
      if (Test-Path $appcmd_path)
      {
        &$appcmd_path set SITE "Default Web Site" "/[path='/'].[path='/'].physicalPath:$releasesunzippath"
      }
      else
      {
        Write-Output "APPCMD.EXE is missing, probably 2003 image. Trying ADSI" 
        
        $siteName = "Default Web Site"
        $iis = [ADSI]"IIS://localhost/W3SVC"
        $site = $iis.psbase.children | where { $_.keyType -eq "IIsWebServer" -AND $_.ServerComment -eq $siteName }
        $path = [ADSI]($site.psbase.path+"/ROOT")
        $path.psbase.properties.path[0] = $releasesunzippath
        #DefaultDoc cannot be configured in web.config for IIS6
        $path.psbase.properties.DefaultDoc[0]="default.aspx,index.aspx,Default.htm,Default.asp,index.html,index.htm,iisstart.htm,index.php"
        $path.psbase.CommitChanges()
      }
  }
  else
  {
    Write-Error "Error: Invalid physical path [$releasesunzippath]" 
    exit 135
  }
POWERSHELL_SCRIPT

  source(powershell_script)
end
