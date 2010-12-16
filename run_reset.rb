require_relative 'lib/password_reset'

preset = PasswordReset.new(ARGV)
preset.run

