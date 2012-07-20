# -*- encoding : utf-8 -*-
class PeopleController < ApplicationController

  ##
  # Get a collection of People
  # 
  # @resource /people
  #
  # @action GET
  # 
  # @optional [String] query The search query to find matching users 
  #
  # @example_request {}
  # @example_response [{"id":1,"name":"Sellitto, Franco"},{"id":2,"name":"Pape, Sebastian"}] 
  #
  # @example_request {"query": "franco"}
  # @example_response [{"id":1,"name":"Sellitto, Franco"}] 
  #
  def index(query = params[:query])
    respond_to do |format|
      format.json {
        people = Person.search(query)
        render json: view_context.json_for(people)
      }
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
                                                                           :pseudonym => params[:person][:pseudonym],
                                                                           :is_group => params[:person][:is_group] || false)
    respond_to do |format|
      format.html
      format.json { render json: view_context.json_for(person, {:label => true}) }
    end
  end
end
