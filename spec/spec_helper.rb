# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  def test_login(user)
    controller.login(user)
  end

  def payment_at(owner, date=DateTime.now, amount=300.5)
    payment = Factory(:payment, :user => owner, :amount => amount)
    payment.created_at = date.to_datetime
    payment.save!
    payment.recalculate_percentages
    payment
  end

  def expense_at(date=DateTime.now, value=10.40)
    expense = Factory(:expense, :value => value)
    expense.created_at = date.to_datetime
    expense.save!
    expense
  end

  def build_valid_user
    Factory(:user, :name => Factory.next(:name), :email => Factory.next(:email), :validated => true)
  end

  def build_not_valid_user
    Factory(:user, :name => Factory.next(:name), :email => Factory.next(:email), :validated => false)
  end

  def build_admin
    Factory(:user, :name => Factory.next(:name), :email => Factory.next(:email), :validated => true, :admin => true)
  end
end
