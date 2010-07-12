maintainer       "RightScale, Inc."
maintainer_email "alex@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Windows Admin recipes and providers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.11"

recipe "win_admin::default", "Not yet implemented"
recipe "win_admin::change_admin_password", "Changes the administrator password"
recipe "win_admin::enable_sql_express_service", "Enables the SQL Express service if disabled"
recipe "win_admin::system_reboot", "Reboots the system"
recipe "win_admin::system_shutdown", "Shuts down the system"
recipe "win_admin::install_firefox", "Installs Mozilla Firefox 3.6"
recipe "win_admin::install_7zip", "Installs 7-Zip"
recipe "win_admin::install_ruby", "Installs Ruby"
recipe "win_admin::patched_start_default_website", "Starts the website named 'Default Web Site' if it is not already running" 
recipe "win_admin::schedule_task", "Schedules a task under the 'administrator' user"


attribute "win_admin/admin_password",
  :display_name => "New administrator password",
  :description => "New administrator password",
  :recipes => ["win_admin::change_admin_password", "win_admin::schedule_task"],
  :required => true

attribute "schtasks/hourly_frequency",
  :display_name => "Task Hourly frequency",
  :description => "Defines the task frequency in hours. Valid values: 1 up to 24. When 24 is specified the 'Task daily time' input is required also.",
  :recipes => ["win_admin::schedule_task"],
  :required => true
  
attribute "schtasks/daily_time",
  :display_name => "Task daily time",
  :description => "The time of the day, based on the server's timezone, to run the task when the 'Hourly frequency' input is set to 24. Format: hh:mm (e.g., 22:30)",
  :recipes => ["win_admin::schedule_task"],
  :required => false