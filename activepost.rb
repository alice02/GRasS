require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/development.sqlite3"
)

class Measurement < ActiveRecord::Base
end

class Record < ActiveRecord::Base
end


srand(12)

id = 1

for i in 1..50 do
  num = rand * 100
  print num, "\n"
  p = Record.new(:depth => num, :latitude => "35.394", :longitude => "135.837", :measurement_id => id)
  p.save
#  sleep(1)
end
