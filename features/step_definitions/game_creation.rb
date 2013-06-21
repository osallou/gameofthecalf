require 'rails/test_help'

When /^the user click on "new game"$/ do
    visit '/games'
    click_button "New game"

end

Then /^a new game is created with one level$/ do
    game = Game.where(:user_id => @user[:id]).first
    level = Level.where(:game_id => game[:id])
    assert 1 == level.count
    if @user[:group_id].nil?
      assert game[:group_id].nil?
    else
      assert game[:group_id] == @user[:group_id]
    end
end

