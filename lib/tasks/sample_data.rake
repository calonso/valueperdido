
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create(:name => "Example",
                        :surname => "User",
                        :email => "user@example.com",
                        :password => "ThePassw0rd",
                        :password_confirmation => "ThePassw0rd")
    admin.toggle!(:admin)

    4.times do |n|
      Event.create!(:name => "Event #{n+1}",
                    :date => Date.today + n * 1.week,
                    :user => admin)
    end

    40.times do |n|
      name = Faker::Name.name
      surname = Faker::Name.last_name
      email = "user-#{n+1}@example.org"
      password = "ThePassw0rd"
      user = User.create!(:name => name,
                          :surname => surname,
                          :email => email,
                          :password => password,
                          :password_confirmation => password)
      Event.all.each do |event|
        bets = event.bets.shuffle[0..Valueperdido::Application.config.max_votes_per_user - 1]
        bets.each do |bet|
          user.votes.create!(:bet => bet,
                             :event => event)
        end

        user.bets.create!(:title => "#{name}'s bet",
                          :description => "This is the #{name}'s bet for this event",
                          :event => event)
      end
    end
  end
end