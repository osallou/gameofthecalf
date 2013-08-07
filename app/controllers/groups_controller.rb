# Base controller for managing groups
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

    users_in_group = User.where(:group_id => @group[:id])

    #@group.users = []
    #users_in_group.each do |user|
    #    @group.users << { :id => user[:id], :email => user[:email] }
    #end

    @users = User.where(:group_id => @group[:id])

    @games = Game.where(:group_id => @group[:id])

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

    config = GameConfig.where(:default => true).first.dup
    config.save
    @group[:config_id] = config[:id]

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

    users_in_group = User.where(:group_id => @group[:id], :fake => 0)
    users_in_group.each do |user|
        user[:group_id] = nil
        user.save
    end
    # Delete all users in group
    users_in_group = User.where(:group_id => @group[:id], :fake => 1)
    users_in_group.each do |user|
        # Delete user games
        user_games = Game.where(:user_id => user[:id])
        user_games.each do |game|
            # Delete game levels
            Level.delete_all(:game_id => game[:id])
            #game_levels.each do |level|
            #    level.destroy
            #end
            game.destroy
        end
        user.destroy
    end

    if ! @group[:config_id].nil?
        config = GameConfig.find(@group[:config_id])
        config.destroy
    end

    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  def forcenextlevel
    @group = Group.find(params[:id])
    authorize! :create, @group
    @game = Game.find(params[:gid])

    matingPlan = @game.generateFakeMatingPlan()

    level = Level.where(:game_id => @game.id, :level => @game[:level]).first
    level[:matingplan] = JSON.generate(matingPlan)
    level.status = Level::STATUS_COMPLETED
    level.save
    @game[:status] = Level::STATUS_COMPLETED
    @game.save

    respond_to do |format|
      format.html { redirect_to @group, notice: 'Game switched to next level.'}
      format.json { render json: matingPlan }
    end
    

  end

  # POST /groups/1/nextlevel
  # POST /groups/1/nextlevel.json
  # Go to next level for all users in group
  def nextlevel
    @group = Group.find(params[:id])
    authorize! :create, @group 
    @group.mate()
    users_in_group = User.where(:group_id => @group[:id])

    #@group.users = []
    #users_in_group.each do |user|
    #    @group.users << { :id => user[:id], :email => user[:email] }
    #end

    @users = User.where(:group_id => @group[:id])

    @games = Game.where(:group_id => @group[:id])

    respond_to do |format|
      format.html { render :show }# show.html.erb
      format.json { render json: @group }
    end 
    
  end

  # POST /groups/1/generateusers/10
  # POST /groups/1/generateusers/10.json
  # Generate a umberof fake accounts
  def generateusers
    @group = Group.find(params[:id])
    authorize! :create, @group

    # Delete all users in group
    users_in_group = User.where(:group_id => @group[:id])
    users_in_group.each do |user|
        user.destroy
    end

    @quantity = params[:quantity]
    @users = Array.new
    Game.generate_new_cattle(@quantity,'group'+@group[:id].to_s,@group[:bulls],@group[:cows])
    uuid = UUID.new
    (1..@quantity.to_i).each do |n|
        user = User.new()
        user.fake = 1
        user.usertype = User::STUDENT
        user.password = SecureRandom.hex(16)
        user.password_confirmation =  user.password
        user.email = 'student-'+uuid.generate+'@fake.org'
        user.group_id = @group[:id]
        user.confirm!
        user.save(:validate => false)
        # Add a game to the user, associate one of the cattles to the user
        game = Game.new(:user_id => user.id, :cattle => n, :group_id => user.group_id, :level => 1, :status => Level::STATUS_NEW)
        game.load_statistics()
        game.save!
        # Create first level e.g. first generation
        level = Level.new(:game_id => game.id, :status => Level::STATUS_NEW, :level => 1)
        level.save!
        @users << user
    end

    respond_to do |format|
        UserMailer.users_created_email(@group, @users).deliver
        format.html 
        format.json { render json: {}.to_json }
    end
  end



end
