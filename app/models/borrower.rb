class Borrower < ApplicationRecord

  # gem bcrypt
  # passwordを暗号化
  # password_digest → パスワード
  # password_confirmation → パスワードの確認
  has_secure_password

  # validates
  validates :name, presence: true, length: { maximum: 30, allow_blank: true }

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
end
