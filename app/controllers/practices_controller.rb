class PracticesController < ApplicationController

  authorize_resource
  before_filter :authenticate_user!  
 	before_filter :validate_authorization

  # GET /practice
  # GET /practice.json
  
  def validate_authorization
  	authorize! :admin, :practice
  end
  
  def index
    @practices = Practice.all
		@practice = Practice.new
		@users = User.all.map {|user| [user.username, user.id]}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @practice }
    end
  end

  # POST /practices
  # POST /practices.json
  def create
    @practice = Practice.new(params[:practice])

    if @practice.save
      identifier = CDAIdentifier.new(:root => "Organization", :extension => @practice.organization)
      provider = Provider.new(:given_name => @practice.name)
      provider.cda_identifiers << identifier
      provider.parent = Provider.root
      provider.save
      @practice.provider = provider
      
      if params[:user] != ''
        user = User.find(params[:user])
        @practice.users << user
        user.save
      end
    end
   
    respond_to do |format|
      if @practice.save
        format.html { redirect_to practices_path, notice: 'Practice was successfully created.' }
        format.json { render json: @practice, status: :created, location: @practice }
      else
        format.html { redirect_to practices_path }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def remove_patients
    Record.where(practice_id: params[:id]).delete
    respond_to do |format|
      format.html { redirect_to :action => :index }
    end
  end
  
  def remove_providers
    practice = Practice.find(params[:id])
    Provider.where(parent_id: practice.provider.id).delete
    
    respond_to do |format|
      format.html { redirect_to :action => :index }
    end
  end
  
  # DELETE /practices/1
  # DELETE /practices/1.json
  def destroy
    @practice = Practice.find(params[:id])
    Record.where(practice_id: @practice.id).delete
    if @practice.provider
      id = @practice.provider.id
      @current_user.teams.each do |tm|
        team.providers.delete(id.to_s)
        team.save!
      end
      @current_user.save!
      @practice.provider.delete
    end
    @practice.destroy

    respond_to do |format|
      format.html { redirect_to :action => :index}
    end
  end
end

