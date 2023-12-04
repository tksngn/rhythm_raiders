module Member::NotificationsHelper
  def transition_path(notification)
    case notification.action_type.to_sym
    when :commented_to_own_post
      post_comment_path(notification.subject.post_comment, anchor: "comment-#{notification.subject.id}")
    when :liked_to_own_post
      post_like_path(notification.subject.post_like)
    when :followed_me
      member_path(notification.subject.follower)
    end
  end
end
