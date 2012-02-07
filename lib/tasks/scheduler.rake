desc "This task is called by the Heroku scheduler add-on"

task :summarize => :environment do
  AccountSummary.summarize Date.yesterday
end

task :post_summary_message => :environment do
  Message.post_summary_message
end
