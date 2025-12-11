# lib/tasks/users.rake
namespace :users do
    desc "Creates a default admin, reviewer, and read_only user"
    task create_defaults: :environment do
      puts "Creating default users..."
      {
        admin:    'admin@example.com',
        reviewer: 'review@example.com',
        read_only: 'reader@example.com'
      }.each do |role, email|
        User.find_or_create_by!(email: email) do |u|
          u.password = 'password' # Simple, predictable password for local dev
          u.role = role
          u.time_zone = 'America/New_York' # Example time zone [cite: 59]
          puts "  Created/Found user: #{email} (#{role})"
        end
      end
    end
end
