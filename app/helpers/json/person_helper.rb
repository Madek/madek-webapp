module Json
  module PersonHelper

    def hash_for_person(person, with = nil)
      h = {
        id: person.id,
        firstname: person.firstname,
        lastname: person.lastname,
        birthdate: person.birthdate,
        deathdate: person.deathdate,
        is_group: person.is_group,
        nationality: person.nationality,
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
      