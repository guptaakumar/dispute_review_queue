puts "Seeding default users..."

{
  admin:    "admin@example.com",
  reviewer: "review@example.com",
  read_only: "reader@example.com"
}.each do |role, email|
  user = User.find_or_initialize_by(email: email)
  user.password = "password" if user.new_record?
  user.role = role
  user.time_zone ||= "America/New_York"
  user.save!

  puts "  #{user.persisted? ? 'Ensured' : 'Created'} #{email} (#{role})"
end

puts "Done."
