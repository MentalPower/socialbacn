# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

if ENV['RAILS_SECRET_TOKEN'].nil? || ENV['RAILS_SECRET_TOKEN'].empty?
  raise ArgumentError.new("Required Rails variable RAILS_SECRET_TOKEN missing")
end

Socialbacn::Application.config.secret_token = ENV['RAILS_SECRET_TOKEN']
