require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def new_game(user, group)
    game = Game.new(:user_id => user[:id], :status => Level::STATUS_NEW, :level => 1)
    if group != nil
      game[:group_id] = group
    end
    game.save!
    # Generate cattle
    Game.generate_new_cattle(1,'game'+game[:id].to_s)
    @levels = []
    level = Level.new(:game_id => game.id, :status => Level::STATUS_NEW, :level => 1)
    level.save!
    return game
  end
  
  setup do
    Settings.simulate = true
    Settings.max_levels = 2
    Game.delete_all()
    Level.delete_all()
  end
  
  test "complete level" do
    
    student = User.where(:email => "student@no-reply.org").first
    game = self.new_game(student, nil)
       
    game.complete_level()
    assert game[:level] == 2
    assert game[:status] == Level::STATUS_NEW
    previouslevel = Level.where(:game_id => game.id, :level => 1).first
    assert previouslevel[:status] == Level::STATUS_COMPLETED
    nextlevel = Level.where(:game_id => game.id, :level => 2).first
    assert nextlevel != nil
    assert nextlevel[:status] == Level::STATUS_NEW
  end
  
  test "complete level when in a group" do
    student = User.where(:email => "student@no-reply.org").first
    game = self.new_game(student, student[:group_id])
 
    game.complete_level()
    # complete level but do not go to next level, professor will do it
    assert game[:level] == 1
    assert game[:status] == Level::STATUS_COMPLETED
    previouslevel = Level.where(:game_id => game.id, :level => 1).first
    assert previouslevel[:status] == Level::STATUS_COMPLETED
    nextlevel = Level.where(:game_id => game.id, :level => 2)
    assert nextlevel.count == 0  
  end
  
  test "switch games in a group to next level" do
    student1 = User.where(:email => "student@no-reply.org").first
    game1 = self.new_game(student1, student1[:group_id])
    game1.complete_level()
    student2 = User.where(:email => "student2@no-reply.org").first
    game2 = self.new_game(student2, student2[:group_id])
    game2.complete_level()  
    group = Group.find(student1[:group_id])
    # In a group, so keep same level
    assert game1[:level] == 1
    assert game2[:level] == 1
    # Now switch level for all games in group
    group.mate()
    game1.reload()
    game2.reload()
    assert game1[:level] == 2
    assert game1[:status] == Level::STATUS_NEW  
    assert game2[:level] == 2
    assert game2[:status] == Level::STATUS_NEW     
  end
  
  test "complete game" do
    student = User.where(:email => "student@no-reply.org").first
    game = self.new_game(student, nil)
    
    game.complete_level()
    game.complete_level()
    assert game[:level] == 2
    assert game[:status] == Level::STATUS_COMPLETED
    previouslevel = Level.where(:game_id => game.id, :level => 2).first
    assert previouslevel[:status] == Level::STATUS_COMPLETED
    nextlevel = Level.where(:game_id => game.id, :level => 3).first
    assert nextlevel == nil  
  end
end
