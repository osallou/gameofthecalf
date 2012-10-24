class GroupsController < ApplicationController

  before_filter :authenticate_user!

  # GET /groups
  # GET /groups.json
  def index
    if params[:group] && params[:group][:search]
      @groups = Group.where(:email => current_user.email).paginate(:page => params[:page], :per_page => 20, :conditions => ['lower(name) LIKE ? ', "%#{params[:group][:search]}%"])
    else
      @groups = Group.where(:email => current_user.email).paginate(:page => params[:page], :per_page => 20)
    end


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups.to_json() }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    authorize! :read, @group

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new
    @group.email =  current_user.email
    @professors = nil
    if User.admin?(current_user)
      @professors = User.where(:usertype => User::PROFESSOR)
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /group/1/edit
  def edit
    @group = Group.find(params[:id])
    
    authorize! :update, @group
    @professors = nil
    if User.admin?(current_user)
      @professors = User.where(:usertype => User::PROFESSOR)
    end

  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    authorize! :create, @group

    @group.email = current_user.email unless User.admin?(current_user)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])
    authorize! :update, @group
    params[:group][:email] = current_user.email unless User.admin?(current_user)
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    authorize! :destroy, @group
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end


end
