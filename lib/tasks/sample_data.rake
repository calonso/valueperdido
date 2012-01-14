
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create(:name => "Example",
                        :surname => "User",
                        :email => "admin@example.org",
                        :password => "ThePassw0rd",
                        :password_confirmation => "ThePassw0rd",
                        :validated => true)
    admin.toggle!(:admin)

    4.times do |n|
      Event.create!(:name => "Event #{n+1}",
                    :date => Date.tomorrow + n.week,
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
                          :password_confirmation => password,
                          :validated => true)

      user.payments.create!({:amount => 100.50,
                             :date => Date.today})
      
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

      2.times do
        user.messages.create!(:message => Faker::Lorem.sentence(7))
      end
    end

    passed = Event.last
    passed[:date] = Date.today
    passed.save!

    bets = Bet.with_votes_for_event(passed.id, 1)
    (0..1).each do |n|
      bet = Bet.find((bets[n]["id"]).to_i)
      bet.selected = true
      bet.money = 10
      bet.winner = true
      bet.rate = 2
      bet.save!
    end

    bet = Bet.find((bets[2]["id"]).to_i)
    bet.selected = true
    bet.money = 10
    bet.save!
  end
end