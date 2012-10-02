require "digest"

class User < ActiveRecord::Base
  attr_accessor :password, :terms
  attr_accessible :name, :surname, :email, :admin, :validated,
                  :password, :password_confirmation, :terms, :passive, :encrypted_password,
                  :salt

  has_many :events
  has_many :bets
  has_many :votes, :dependent => :destroy
  has_many :payments
  has_many :messages, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
=begin
  validates :name, :presence => true,
                   :length => { :maximum => 45 }
  validates :surname, :presence => true,
                      :length => { :maximum => 45 }
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
  # The password is required on creation, then, only validated if present
  validates :password, :confirmation => true,
                       :length => { :within => 8..45 },
                       :unless => Proc.new { |a| a.password.blank? }
  validates :password, :presence => true, :on => :create
  validates :terms, :acceptance => true, :on => :create
  validates :percentage, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0 }


  before_save :encrypt_password, :unless => Proc.new { |a| a.password.blank? }
=end
  default_scope :order => "users.surname ASC, users.name ASC"
  scope :validated, where(:validated => true)

  def has_password? (submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def do_destroy
    total = AccountSummary.total_money
    deleted_amount = (self.percentage * total / 100).round(2)
    Expense.create!(:value => deleted_amount,
                    :description => "#{self.surname}, #{self.name} deletion")
    self.destroy
    User.validated.each do |user|
      user_amount = total * user.percentage / 100
      user.percentage = user_amount == 0 ? 0 : (user_amount / (total - deleted_amount)) * 100
      user.save!
    end
  end

  # Here adding a class method User.authenticate, self is User class, not an instance
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    (user && user.has_password?(submitted_password) && user.validated?) ? user : nil
  end

  def self.auth_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def self.any_user_first_payed_between?(start, finish)
    data = self.connection.execute(sanitize_sql ["SELECT COUNT(*) AS count FROM users AS u
      INNER JOIN (SELECT user_id, MIN(created_at) AS payment_date FROM payments group by user_id)
        AS p ON u.id = p.user_id WHERE validated = 't' AND payment_date BETWEEN ? AND ?", start, finish])
    data[0]['count'].to_i > 0
  end

  private

   def encrypt_password
     # To ensure that the salt is updated if the password is updated
      self.salt = make_salt unless has_password?(password)
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
