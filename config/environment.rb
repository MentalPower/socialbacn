# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Socialbacn::Application.initialize!

#Modify the id column to be 64bits
NativeDbTypesOverride.configure({
  mysql: {
    primary_key: { name: "BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY"}
  }
})
