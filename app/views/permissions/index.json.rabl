node do 
  
 h = {:public => {},
      :you => {}}

 # PUBLIC  
 [:view, :edit, :download].each do |action|
   h[:public][action] = @media_resources.select(&action).map(&:id)
 end
 
 # YOU
 [:view, :edit, :download, :manage].each do |action|
   h[:you][action] = @media_resources.select do |me|
     current_user.authorized?(action, me)
   end.map(&:id)
 end
  
 h
end
