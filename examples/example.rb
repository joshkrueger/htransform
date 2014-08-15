#!/usr/bin/ruby

require 'htransform'
require 'example_transform'

in_hash = {
  "fname" => "JOHN",
  "lname" => "doe",
  "phonenum" => "555-123-1122",
  "email" => "j.doe@example.com",
  "state_id" => {
    "number" => "d123456",
    "state" => "il",  
    "type" => "drivers"
  }
}

desired_hash = {
  :first_name => "John",
  :last_name => "Doe",
  :full_name => "John Doe",
  :contact_info => {
    :phone_number => "5551231122",
    :email_address => "j.doe@example.com"
  },
  :state_identification => {
    :issuing_state => "IL",
    :type => "drivers",
    :number => "D123456"
  }
}

result_hash = ExampleTransform.convert(in_hash)

puts "The Hash Transformation worked correctly!" if result_hash == desired_hash
