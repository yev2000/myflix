class YevWorker
  include Sidekiq::Worker

  def perform(str)
    puts "<> I am a Yev Worker given string: #{str}"
    puts "The environment is: #{ENV['RAILS_ENV']}"
    result = AppMailer.hardcoded_notify("yevworker@yevco.com", "someone@yevco.com", "test email from YevWorker", str).deliver
    puts "result of appmailer: #{result}"
  end
end
