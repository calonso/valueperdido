require 'spec_helper'

describe Expense do
  before (:each) do
    @attr = {
        :date => Date.today,
        :value => 15.5,
        :description => "The description" }
  end

  it "should create a new instance given valid attributes" do
    Expense.create! @attr
  end

  it "should have the right attributes" do
    expense = Expense.create @attr
    expense.date.should == @attr[:date]
    expense.value.should == @attr[:value]
    expense.description.should == @attr[:description]
  end

  describe "validations" do
    it "should require a date" do
      invalid_expense = Expense.new @attr.merge(:date => nil)
      invalid_expense.should_not be_valid
    end

    it "should reject invalid dates" do
      invalid_expense = Expense.new @attr.merge(:date => "abc")
      invalid_expense.should_not be_valid
    end

    it "should require a value" do
      invalid_expense = Expense.new @attr.merge(:value => nil)
      invalid_expense.should_not be_valid
    end

    it "should reject invalid values" do
      invalid_expense = Expense.new @attr.merge(:value => "a99")
      invalid_expense.should_not be_valid
    end

    it "should accept valid values" do
      valid_values = %w[90 90.50 0.90 9000.1]
      valid_values.each do |val|
        valid_expense = Expense.new @attr.merge(:value => val)
        valid_expense.should be_valid
      end
    end

    it "should require a description" do
      invalid_expense = Expense.new @attr.merge(:description => nil)
      invalid_expense.should_not be_valid
    end

    it "should reject blank descriptions" do
      invalid_expense = Expense.new @attr.merge(:description => '')
      invalid_expense.should_not be_valid
    end

    it "should reject too long descriptions" do
      invalid_expense = Expense.new @attr.merge(:description => 'a' * 256)
      invalid_expense.should_not be_valid
    end
  end

  describe "callbacks" do
    it "should summarize if expense was before today" do
      lambda do
        Expense.create(:date => Date.yesterday, :value => 100, :description => "desc")
      end.should change(AccountSummary, :count).by(1)
    end

    it "should not summarize if today or in future" do
      lambda do
        Expense.create(:date => Date.tomorrow, :value => 100, :description => "desc")
      end.should_not change(AccountSummary, :count)
    end

    it "should pass the right date" do
      Expense.create(:date => Date.yesterday, :value => 100, :description => "desc")
      AccountSummary.last.date.should == Date.yesterday
    end
  end
end
