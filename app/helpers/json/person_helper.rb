module Json
  module PersonHelper

    def hash_for_person(person, with = nil)
      {
        id: person.id,
        firstname: person.firstname,
        lastname: person.lastname,
        birthdate: person.birthdate,
        deathdate: person.deathdate,
        is_group: person.is_group,
        nationality: person.nationality,
        pseudonym: person.pseudonym
      }
    end
  end
end
      