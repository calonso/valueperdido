# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  surname            :string(255)
#  email              :string(255)
#  admin              :boolean(1)      default(FALSE)
#  validated          :boolean(1)      default(FALSE)
#  encrypted_password :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require "digest"
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :surname, :email, :admin, :validated, :password, :password_confirmation

  has_many :events
  has_many :bets
  has_many :votes, :dependent => :destroy
  has_many :payments
  has_many :messages, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

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


  before_save :encrypt_password, :unless => Proc.new { |a| a.password.blank? }

  default_scope :order => "users.surname ASC, users.name ASC"

  def has_password? (submitted_password)
    encrypted_password == encrypt(submitted_password)
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
