class Array
  
  #sellittf# support for Kaminari
  def page(n)
    Kaminari.paginate_array(self).page(n)    
  end
  
end