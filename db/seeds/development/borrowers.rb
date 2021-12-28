10.times do |n|
  name = "borrower#{n}"
  email = "#{name}@example.com"
  borrower = Borrower.find_or_initialize_by(email: email, activated: true)

  if borrower.new_record?
    borrower.name = name
    borrower.password = "password"
    borrower.save!
  end
end

puts "borrowers = #{Borrower.count}"