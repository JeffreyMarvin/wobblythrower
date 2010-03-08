# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_documentr_session',
  :secret      => '56fb604d2f4cf90d70ce7d7bdebb20cbf8296568e476d4bde1ad45f019f2ecb4780724cda84dbc2c7c85d89d56d083ffd1bf335d838c9fcfaf68da760936d294'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
