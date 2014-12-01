require "socket" 
require 'etc'

class BuildInfo < ActiveRecord::Base

  self.table_name = "build_info"

  def self.append_record
    # get build machine name
    machine_name = Socket.gethostname 
    
    # get user name
    user_name = Etc.getlogin

    # create a new record and persist it
    new_record = self.create(build_machine: machine_name, build_user: user_name)
  end

  def self.latest_build_string
    build_info = self.last
    build_info ? "Built on #{build_info.created_at.to_s} by #{build_info.build_user}@#{build_info.build_machine}" : ""
  end
end