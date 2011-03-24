# -*- encoding : utf-8 -*-
class PeopleController < ApplicationController
  
  def index
    people = Person.search(params[:tag])
    
    respond_to do |format|
      format.html
      format.js { render :json => people.map {|x| {:caption => x.to_s, :value => x.id} } }
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
    person = Person.create(params[:person])
    
    respond_to do |format|
      format.html
      #format.js { render :json => {:title => person.to_s, :value => person.id} }
      format.js { render :json => {:label => person.to_s, :id => person.id} }
    end
  end
end
