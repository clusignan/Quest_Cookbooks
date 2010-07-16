# Cookbook Name:: win_db_mssql
# Recipe:: backup_database_to_s3
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

# backs up the database
win_db_mssql_powershell_database @node[:db_sqlserver][:database_name] do
  machine_type = @node[:kernel][:machine]
  backup_dir_path @node[:db_sqlserver][:backup][:database_backup_dir]
  backup_file_name_format @node[:db_sqlserver][:backup][:backup_file_name_format]
  existing_backup_file_name_pattern @node[:db_sqlserver][:backup][:existing_backup_file_name_pattern]
  server_name @node[:db_sqlserver][:server_name]
  force_restore false
  zip_backup true
  action :backup
end

#list all the backups
powershell "list the backups" do
  parameters({'BKPATH' => @node[:db_sqlserver][:backup][:database_backup_dir]})

  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
    ls $env:BKPATH
POWERSHELL_SCRIPT

  source(powershell_script)
end

#upload dump to s3
win_aws_powershell_s3provider "download mssql dump from bucket" do
  access_key_id @node[:aws][:access_key_id]
  secret_access_key @node[:aws][:secret_access_key]
  s3_bucket @node[:s3][:bucket_backups]
  #if file_path is a directory, the latest file in the directory will be uploaded
  file_path @node[:db_sqlserver][:backup][:database_backup_dir]
  action :put
end