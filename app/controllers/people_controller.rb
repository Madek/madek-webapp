# -*- encoding : utf-8 -*-
class PeopleController < ApplicationController
  
  def index
    people = Person.search(params[:tag])
    
    respond_to do |format|
      format.html
      format.json { render :json => people.map {|x| {:caption => x.to_s, :value => x.id} } }
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    # OPTIMIZE model uniqueness validation
    person = Person.find_or_create_by_firstname_and_lastname_and_pseudonym(:firstname => params[:person][:firstname],
                                                                           :lastname => params[:person][:lastname],
                                                                           :pseudonym => params[:person][:pseudonym])
    
    respond_to do |format|
      format.html
      format.json { render :json => {:label => person.to_s, :id => person.id} }
    end
  end
end
