require "validator/email_validator"

class Borrower < ApplicationRecord
  include TokenGenerateService

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
    burrowers = Borrower.where.not(id: id)
    burrowers.find_by_activated(email).present?
  end

  def remember(jti)
    update!(refresh_jti: jti)
  end

  def forget
    update!(refresh_jti: nil)
  end

  def response_json(payload = {})
    as_json(only: [:id, :name]).merge(payload).with_indifferent_access
  end

  private

  # email小文字化
  def downcase_email
    self.email.downcase! if email
  end
end
