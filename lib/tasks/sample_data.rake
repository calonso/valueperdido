
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
    99.times do |n|
      name = Faker::Name.name
      surname = Faker::Name.last_name
      email = "user-#{n+1}@example.org"
      password = "ThePassw0rd"
      User.create!(:name => name,
                    :surname => surname,
                    :email => email,
                    :password => password,
                    :password_confirmation => password)
    end
  end
end