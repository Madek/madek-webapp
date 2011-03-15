require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Working with sets", %q{
  Grouping media entries into sets and removing them from 
} do


  background do
    set_up_world
    helmut = create_user("Helmut Kohl", "helmi", "schweinsmagen")
    gorbatschow = create_user("Mikhail Gorbachev", "gorbi", "glasnost")
  end


end