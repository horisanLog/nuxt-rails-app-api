require "validator/email_validator"

class Borrower < ApplicationRecord
  # バリデーション直前
  before_validation :downcase_email

  # gem bcrypt
  # passwordを暗号化
  # password_digest → パスワード
  # password_confirmation → パスワードの確認
  has_secure_password

  ## validates
  validates :name, presence: true, length: { maximum: 30, allow_blank: true }
  
  validates :email, presence: true,
                    email: { allow_blank: true }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                       length: { 
                         minimum: 8
                       },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password
                       },
                       allow_nil: true
  
  validates :activated, inclusion: { in: [ true, false ] }

  ## methods
  # class method  ###########################
  class << self
    # emailからアクティブなユーザーを返す
    def find_by_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # class method end #########################

  # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
  def email_activated?
    users = Borrower.where.not(id: id)
    users.find_by_activated(email).present?
  end

  private

  # email小文字化
  def downcase_email
    self.email.downcase! if email
  end
end
