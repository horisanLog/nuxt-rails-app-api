require "test_helper"

class BorrowerTest < ActiveSupport::TestCase
  def setup
    @borrower = active_borrower
  end

  test "name_validation" do
    # 入力必須
    borrower  = Borrower.new(email: "test@example.com", password: "password")
    borrower.save
    required_msg = ["名前を入力してください"]
    assert_equal(required_msg, borrower.errors.full_messages)


    # 文字数制限
    max = 30
    name = "a" * (max + 1)
    borrower.name = name
    borrower.save
    maxlength_msg = ["名前は30文字以内で入力してください"]
    assert_equal(maxlength_msg, borrower.errors.full_messages)

    # 30文字以内は正しく保存されているか
    name = "あ" * max
    borrower.name = name
    assert_difference("Borrower.count", 1) do
      borrower.save
    end
  end

  test "email_validation" do
    # 入力必須
    borrower = Borrower.new(name: "test", password: "password")
    borrower.save
    required_msg = ["メールアドレスを入力してください"]
    assert_equal(required_msg, borrower.errors.full_messages)

    # 文字数制限
    max = 255
    domain = "@example.com"
    email = "a" * ((max + 1) - domain.length) + domain
    assert max < email.length

    borrower.email = email
    borrower.save
    maxlength_msg = ["メールアドレスは255文字以内で入力してください"]
    assert_equal(maxlength_msg, borrower.errors.full_messages)

    # 書式チェック format = /\A\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/
    ok_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    ok_emails.each do |email|
      borrower.email = email
      assert borrower.save
    end

    ng_emails = %w(
      aaa
      a.ex.com
      メール@ex.com
      a~a@ex.com
      a@|.com
      a@ex.
      .a@ex.com
      a＠ex.com
      Ａ@ex.com
      a@?,com
      １@ex.com
      "a"@ex.com
      a@ex@co.jp
    )
  
    ng_emails.each do |email|
      borrower.email = email
      borrower.save
      format_msg = ["メールアドレスは不正な値です"]
      assert_equal(format_msg, borrower.errors.full_messages)
    end
  end

  test "email_downcase" do
    email = "USER@EXAMPLE.COM"
    borrower = Borrower.new(email: email)
    borrower.save
    assert borrower.email == email.downcase
  end

  test "active_borrower_uniqueness" do
    email = "test@example.com"

    count = 3
    assert_difference("Borrower.count", count) do
      count.times do |n|
        Borrower.create(name: "test", email: email, password: "password")
      end
    end

    active_borrower = Borrower.find_by(email: email)
    active_borrower.update!(activated: true)
    assert active_borrower.activated

    assert_no_difference("Borrower.count") do
      borrower = Borrower.new(name: "test", email: email, password: "password")
      borrower.save
      uniqueness_msg = ["メールアドレスはすでに存在します"]
      assert_equal(uniqueness_msg, borrower.errors.full_messages)
    end

    active_borrower.destroy!
    assert_difference("Borrower.count", 1) do
      Borrower.create(name: "test", email: email, password: "password", activated: true)
    end

    assert_equal(1, Borrower.where(email: email, activated: true).count)
  end

  test "password_validation" do
    # 入力必須
    borrower = Borrower.new(name: "test", email: "test@example.com")
    borrower.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, borrower.errors.full_messages)

    # min文字以上
    min = 8
    borrower.password = "a" * (min - 1)
    borrower.save
    minlength_msg = ["パスワードは8文字以上で入力してください"]
    assert_equal(minlength_msg, borrower.errors.full_messages)

    # max文字以下
    max = 72
    borrower.password = "a" * (max + 1)
    borrower.save
    maxlength_msg = ["パスワードは72文字以内で入力してください"]
    assert_equal(maxlength_msg, borrower.errors.full_messages)

    # 書式チェック VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    ok_passwords = %w(
      pass---word
      ________
      12341234
      ____pass
      pass----
      PASSWORD
    )
    ok_passwords.each do |pass|
      borrower.password = pass
      assert borrower.save
    end

    ng_passwords = %w(
      pass/word
      pass.word
      |~=?+"a"
      １２３４５６７８
      ＡＢＣＤＥＦＧＨ
      password@
    )
    format_msg = ["パスワードは半角英数字•ﾊｲﾌﾝ•ｱﾝﾀﾞｰﾊﾞｰが使えます"]
    ng_passwords.each do |pass|
      borrower.password = pass
      borrower.save
      assert_equal(format_msg, borrower.errors.full_messages)
    end
  end
end
