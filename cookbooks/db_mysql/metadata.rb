maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "MySQL recipes and providers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.1"


recipe 'db_mysql::default', 'Not yet implemented.'
recipe "db_mysql::install_odbc_connector", "Installs the MySQL ODBC Connector."
