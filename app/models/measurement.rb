class Measurement < ActiveRecord::Base

  has_many :records, :dependent => :delete_all

end
