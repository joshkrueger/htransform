require 'htransform'

class ExampleTransform < HTransform
  transform do

    input "fname" => :first_name, :via => :capitalize
    input :from => "lname", :to => :last_name, :via => lambda { |x| x.capitalize }
    input "phonenum" => [:contact_info, :phone_number], :via => lambda { |p| p.gsub("-", "") }
    input "email" => [:contact_info, :email_address]

    input_multiple :from => ["fname", "lname"], :to => :full_name, :via => lambda { |x| x.map{ |v| v.capitalize }.join(" ") }

    input ["state_id", "state"] => [:state_identification, :issuing_state], :via => :upcase
    input ["state_id", "number"] => [:state_identification, :number], :via => :upcase
    input ["state_id", "type"] => [:state_identification, :type]

  end
end
