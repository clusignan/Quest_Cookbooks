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

powershell "Install the MySQL ODBC Connector from attachment" do
  attachments_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files', 'install_odbc_connector'))
  parameters({'ATTACHMENTS_PATH' => attachments_path})
  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
    $connector_path = 'C:\Program Files\MySQL\Connector ODBC 5.1'
	
    #check to see if the package is already installed
    if (Test-Path ($connector_path)) { 
      Write-Output "*** MySQL ODBC Connector already installed in [$connector_path]. Skipping installation."
    }
    Else {
      cd "$env:ATTACHMENTS_PATH"
      #create multiple directories and continue if directory exists
      New-Item  c:\tmp -type directory -ErrorAction SilentlyContinue > $null

      Write-Output "*** Installing MySQL ODBC Connector msi"
      cmd /c msiexec /package mysql-connector-odbc-5.1.8-winx64.msi /quiet /l* c:\tmp\mysql-connector-msi-install.log

      exit 0
	  }
POWERSHELL_SCRIPT

  source(powershell_script)
end
