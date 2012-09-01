# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_amazon_facebook_session',
  :secret      => 'e2843ed09cca1e306ca4aa2f67479793d838aa40d278eab97d6d0be7aa2557cd280197b9c3c8185bd2f4bd4317920b852c64fd7a6862fabfa70e6613426f4412'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
