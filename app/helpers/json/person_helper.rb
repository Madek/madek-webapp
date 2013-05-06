module Json
  module PersonHelper

    def hash_for_person(person, with = nil)
      h = {
        id: person.id,
        first_name: person.first_name,
        last_name: person.last_name,
        date_of_birth: person.date_of_birth,
        date_of_death: person.date_of_death,
        is_group: person.is_group,
        pseudonym: person.pseudonym
      }
      
      if with ||=nil
        if with[:label]
          h[:label] = person.to_s
        end
      end
      
      h
    end
  end
end
      
