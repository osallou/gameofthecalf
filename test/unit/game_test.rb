require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def new_game(user)
    game = Game.new(:user_id => user[:id], :status => Level::STATUS_NEW, :level => 1)
    game.save!
    # Generate cattle
    Game.generate_new_cattle(1,'game'+game[:id].to_s)
    @levels = []
    level = Level.new(:game_id => game.id, :status => Level::STATUS_NEW, :level => 1)
    level.save!
    return game
  end
  
  test "complete level" do
    Settings.simulate = true
    
    Game.delete_all()
    Level.delete_all()
    
    student = User.where(:email => "student@no-reply.org").first
    game = self.new_game(student)
    
    
    game.complete_level()
    assert game[:level] == 2
    nextlevel = Level.where(:game_id => game.id, :level => 2).first
    assert nextlevel != nil
  end
end
