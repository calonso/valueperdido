
namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    NUM_USERS = 40
    Rake::Task['db:reset'].invoke
    admin = User.create(:name => "Example",
                        :surname => "User",
                        :email => "admin@example.org",
                        :password => "ThePassw0rd",
                        :password_confirmation => "ThePassw0rd",
                        :validated => true)
    admin.toggle!(:admin)

    payment = admin.payments.create!(:amount => 100.5)
    payment.save!
    payment.recalculate_percentages

    4.times do |n|
      Event.create!(:name => "Event #{n+1}",
                    :date => Date.tomorrow + n.week,
                    :user => admin)
      Expense.create!(:value => 10.1 * n,
                      :description => "Expense: #{n}" )
    end

    admin_bet = admin.bets.create!(:title => "Admin's bet",
                       :description => "This is the Admin's bet for this event",
                       :event_id => Event.first.id)
    admin_bet.process_update(:status => Bet::STATUS_PERFORMED,
            :money => 10, :odds => 2)


    NUM_USERS.times do |n|
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

      payment = user.payments.create!(:amount => 100.5)
      payment.save!
      payment.recalculate_percentages

      Event.all.each do |event|
        bets = event.bets.shuffle[0..Valueperdido::Application.config.max_votes_per_user - 1]
        bets.each do |bet|
          user.votes.create!(:bet => bet,
                             :event => event)
        end

        user.bets.create!(:title => "#{name}'s bet",
                          :description => "This is the #{name}'s bet for this event",
                          :event_id => event.id)
      end

      2.times do
        user.messages.create!(:message => Faker::Lorem.sentence(7))
      end
    end

    passed = Event.last
    passed.save!

    bets = Bet.with_votes_for_event(passed.id, 1)
    (0..1).each do |n|
      bet = Bet.find((bets[n]["id"]).to_i)
      bet.process_update(:status => Bet::STATUS_PERFORMED,
        :money => 10, :odds => 2)
      bet.process_update(:status => Bet::STATUS_WINNER,
        :earned => 20)
    end

    bet = Bet.find((bets[2]["id"]).to_i)
    bet.process_update(:status => Bet::STATUS_PERFORMED,
      :money => 10, :odds => 2)

    bet = Bet.find((bets[3]["id"]).to_i)
    bet.process_update(:status => Bet::STATUS_PERFORMED,
          :money => 10, :odds => 2)
    bet.process_update(:status => Bet::STATUS_LOSER)

    admin_bet.process_update(:status => Bet::STATUS_WINNER,
            :earned => 20)

    AccountSummary.summarize Date.yesterday, false
    AccountSummary.summarize Date.today, false

    Message.post_summary_message
  end
end