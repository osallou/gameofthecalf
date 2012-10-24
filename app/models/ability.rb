class Ability
  include CanCan::Ability

  def initialize(user)
   user ||= User.new

   if User.admin?(user)
     can :manage, :all
   elsif user.usertype == User::PROFESSOR
     can :create, Group
     can [:read, :update, :destroy], Group do |group|
          user.group_id == group.id
     end
     can :create, User, :usertype =>  User::STUDENT

     can [:read, :update, :destroy], User do |student|
          student_group = Group.find(user.group_id)
          student_group !=nil && user.email == student_group.email
     end

   end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
