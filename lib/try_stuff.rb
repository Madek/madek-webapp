
class MetaDate
  attr_accessor :timestamp, 
                :timezone,
                :free_text
end



module TryStuff


SerDate =%Q{---
- !ruby/object:MetaDate            
  free_text: 08.12.2010, 14:28     
  timestamp: 1291814880            
  timezone: "+01:00"               
}

end
