# Cookbook Name:: win_admin
# Recipe:: install_firefox
#
# Copyright 2010, RightScale, Inc.
#
# All rights reserved

powershell "Installs Mozilla Firefox" do
  attachments_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files', 'install_firefox'))
  parameters({'ATTACHMENTS_PATH' => attachments_path})

  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
    cd "$env:ATTACHMENTS_PATH"
    
    $file = "Firefox%20Setup%203.6.exe"
    $url =  "http://releases.mozilla.org/pub/mozilla.org/firefox/releases/3.6/win32/en-US/"+$file
    
    cmd /c "C:\Program Files\RightScale\SandBox\Git\bin\curl.exe" --max-time 120 -C - -O $url

    cmd /c $file /INI=./firefox_quiet_install.ini
    
    rm $file
POWERSHELL_SCRIPT

  source(powershell_script)
end