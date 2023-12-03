class Member::LikesController < ApplicationController

  def create
    @created_track = CreatedTrack.find(params[:created_track_id])

    # 既存のLikeを検索
    @like = Like.find_by(member_id: current_member.id, created_track_id: @created_track.id)

    if @like
      # 既存のLikeがある場合は削除
      @like.destroy
    else
      # 既存のLikeがない場合は新規作成
      @like = Like.new(member_id: current_member.id, created_track_id: @created_track.id)
      unless @like.save
        # エラーメッセージを表示
        render json: { error: 'Failed to create like' }, status: :unprocessable_entity
        return
      end
    end

    # いいねの数を更新
    like_count = Like.where(created_track_id: params[:created_track_id]).count
    render json: { like_count: like_count }
  end

  def destroy
    created_track = CreatedTrack.find(params[:created_track_id])
    like = current_member.likes.find_by(created_track_id: created_track.id)
    like.destroy
    redirect_to member_created_tracks_path(created_track)
  end
end

