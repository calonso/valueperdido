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

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
                   :length => { :maximum => 45 }
  validates :surname, :presence => true,
                      :length => { :maximum => 45 }
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 8..45 }

  before_save :encrypt_password

  def has_password? (submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  # Here adding a class method User.authenticate, self is User class, not an instance
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
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