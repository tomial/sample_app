class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_secure_password

  # 生成token摘要
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, costs: cost)
  end

  # 生成新token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 记住我
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))

    remember_digest
  end

  # 忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 验证token
  def authenticated?(remember_token)
    # Bcrypt::Password.new(remember_digest) == remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def session_token
    remember_digest || remember
  end
end
