class Api::V1::UsersController < ApplicationController
  before_action :find_followed_user

  def follow
    current_user.active_follows.find_or_create_by!(followed: @followed_user)

    render_json(:created, {
      follow: {
        follower_id: current_user.id,
        followed_id: @followed_user.id
      }
    })
  end

  def unfollow
    follow_record = current_user.active_follows.find_by!(followed: @followed_user)
    follow_record.destroy

    render_json(:ok)
  end

  private

  def find_followed_user
    @followed_user = User.find(params[:followed_id])
  end
end
