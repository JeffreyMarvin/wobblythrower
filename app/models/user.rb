class User < ActiveRecord::Base
  validates_uniqueness_of :username
  validates_length_of :password, :within => 4..40
  
  # If a user matching the credentials is found, returns the User object.
  # If no matching user is found, returns nil.
end
