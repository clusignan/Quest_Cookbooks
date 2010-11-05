# Cookbook Name:: aws
# Recipe:: terminate_instance
#
# Copyright 2010, RightScale, Inc.
#
# All rights reserved
#

aws_elb "terminate current instance provider call" do
  access_key_id @node[:aws][:access_key_id]
  secret_access_key @node[:aws][:secret_access_key]
  action :terminate_instance
end