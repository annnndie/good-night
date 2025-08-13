class Api::V1::UsersController < ApplicationController
  before_action :find_followed_user

  def follow
    current_user.follow(@followed_user)

    render_json(:created)
  end

  def unfollow
    current_user.unfollow(@followed_user)

    render_json(:ok)
  end

  private

  def find_followed_user
    @followed_user = User.find(params[:followed_id])
  end
end
