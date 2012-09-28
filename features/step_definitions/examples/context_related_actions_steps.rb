# coding: utf-8

Then /^I can open the context actions drop down and see the following actions in the following order:$/ do |table|
  page.execute_script %Q{ $(".action_menu:first .action_menu_list").show(); }
  menu = find(".action_menu")
  table.hashes.each do |hash|
    case hash[:action]
      when "edit"
        menu.find("li", :text => "Editieren")
      when "favorite"
        menu.find("li", :text => "Favorisieren")
      when "permissions"
        menu.find("li", :text => "Zugriffsberechtigungen")
      when "add to set"  
        menu.find("li", :text => "Zu Set hinzufügen/entfernen")
      when "set highlight"  
        menu.find("li", :text => "Hervorheben")
      when "delete"  
        menu.find("li", :text => "Löschen")
      when "export"  
        menu.find("li", :text => "Exportieren")
      when "create group"  
        menu.find("li", :text => "Neue Arbeitsgruppe")
      when "import"  
        menu.find("li", :text => "Importieren")
      when "browse"
        menu.find("li", :text => "Erkunden") if MediaResource.find(current_path.gsub(/\D/, "").to_i).meta_data.for_meta_terms.exists?
      when "create set"
        menu.find("li", :text => "Neues Set")
      when "edit changes to filter settings"
        menu.find("li", :text => "Einstellungen ändern")
      else
        raise "#{hash} action not found"
    end
  end
end