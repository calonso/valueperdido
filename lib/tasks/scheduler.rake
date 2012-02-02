desc "This task is called by the Heroku scheduler add-on"

task :summarize => :environment do
    AccountSummary.summarize Date.yesterday
end
