# Group is used to group a set of Users.
# User is in one group only.
# Group can be seen as a classroom owner by a professor.
class Group < ActiveRecord::Base
  attr_accessible :description, :name, :email, :levels, :bulls, :cows
  # TODO add transient field for users (groups_controller sets users)


  scope :recent, order("created_at desc")

  has_many :users, :dependent => :nullify
  has_many :games, :dependent => :nullify

  def mate()
    # Do mating for a group of user   
    games = Game.where(:group_id => self[:id])
    matingplans = {}
    gen = nil
    games.each do |game|
      gen = game[:level]
      level = Level.where(:game_id => game[:id], :level => game[:level]).first
      matingplans[game[:cattle]] = JSON.parse(level[:matingplan])
      if game[:level]< Settings.max_levels
        # Go to next level
        game[:level] += 1
        game[:status] = Level::STATUS_NEW

        level = Level.new(:game_id => game.id, :status => Level::STATUS_NEW, :level => game[:level])
        level.save!
      else
        game[:status] = Level::STATUS_COMPLETED
      end
      game.save
    end
    #TODO write matingplan
    do_mating = Game.writeMatingPlan("group"+self[:id].to_s, gen+1, matingplans)
    if do_mating
      Game.mate("group"+self[:id].to_s, gen)
    end
  end

end
