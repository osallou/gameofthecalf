class GroupsController < ApplicationController

  before_filter :authenticate_user! && can? :manage, Groups 

end
