# lib/tasks/deploy.rake

require 'paratrooper'

namespace :deploy do
  desc 'Deploy app in staging environment'
  task staging: :environment do
    BuildInfo.append_record

    ## should I also run figaro heroku:set -e production --app myflix-yev-staging ??

    deployment = Paratrooper::Deploy.new("myflix-yev-staging", tag: 'staging')

    deployment.deploy
  end

  desc 'Deploy app in production environment'
  task production: :environment do
    BuildInfo.append_record

    ## should I also run figaro heroku:set -e production --app myflix-yev??

    deployment = Paratrooper::Deploy.new("myflix-yev") do |deploy|
      deploy.tag              = 'production'
      deploy.match_tag        = 'staging'
    end

    deployment.deploy
  end

  desc 'test out a shell command'
  task :dateshell do
    command_to_run = 'heroku config:set MYFLIX_BUILD_DATE="' + Time.now.to_s + '"'
    puts "will issue this command:"
    puts command_to_run
  end

  desc 'test out a heroku command'
  task :setvarheroku do
    command_to_run = 'heroku config:set MYFLIX_BUILD_DATE="' + Time.now.to_s + '" --app myflix-yev-staging'
    puts "will issue this command:"
    puts command_to_run
    system(command_to_run)
    puts "Now I'm done"
  end

  desc 'test out build info creation'
  task setbuildinfo: :environment do
    BuildInfo.append_record
    puts "Latest build info now: #{BuildInfo.latest_build_string}"
  end

end
