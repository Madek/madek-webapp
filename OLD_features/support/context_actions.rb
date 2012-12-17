# coding: utf-8

def find_context_action name
  page.execute_script %Q{ $(".action_menu:first .action_menu_list").show(); } 
  menu = find(".action_menu")
  case name
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
    when "show graph"
      menu.find("li", :text => "Graph berechnen")
    when "save display settings"
      menu.find("li", :text => "Darstellung speichern")
    when "set cover"
      menu.find("li", :text => "Titelbild")
    else
      raise "#{name} action not found"
  end
end