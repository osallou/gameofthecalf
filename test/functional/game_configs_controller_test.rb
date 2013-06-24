require 'test_helper'

class GameConfigsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @game_config = game_configs(:one)
    user = users(:admin)
    sign_in user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_config" do
    assert_difference('GameConfig.count') do
      post :create, game_config: { default: @game_config.default, mortality: @game_config.mortality, nbtrait: @game_config.nbtrait }
    end

    assert_redirected_to game_config_path(assigns(:game_config))
  end

  test "should show game_config" do
    get :show, id: @game_config
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_config
    assert_response :success
  end

  test "should update game_config" do
    put :update, id: @game_config, game_config: { default: @game_config.default, mortality: @game_config.mortality, nbtrait: @game_config.nbtrait }
    assert_redirected_to game_config_path(assigns(:game_config))
  end

  test "should destroy game_config" do
    assert_difference('GameConfig.count', -1) do
      delete :destroy, id: @game_config
    end

    assert_redirected_to game_configs_path
  end
end
