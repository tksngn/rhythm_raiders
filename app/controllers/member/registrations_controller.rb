# frozen_string_literal: true

class Member::RegistrationsController < Devise::RegistrationsController
  # prepend_before_action :require_no_authentication, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :ensure_normal_member, only: %i[update destroy]

  def ensure_normal_member
    if resource.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストメンバーの更新・削除はできません。'
    end
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # def create
  #   build_resource(sign_up_params)

  #   resource.save
  #   yield resource if block_given?
  #   if resource.persisted?
  #     if resource.active_for_authentication?
  #       sign_up(resource_name, resource)
  #       redirect_to new_member_session_path # ログイン画面にリダイレクト
  #     else
  #       set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
  #       expire_data_after_sign_in!
  #       respond_with resource, location: after_inactive_sign_up_path_for(resource)
  #     end
  #   else
  #     clean_up_passwords resource
  #     set_minimum_password_length
  #     puts resource.errors.full_messages # バリデーションエラーのメッセージを表示
  #     respond_with resource
  #   end
  # end

  def destroy
    resource.update(is_active: false)  # メンバーを非アクティブに設定
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :creater_name, :profile_image, :email, :password, :password_confirmation, :phone_number, :gender, :agreement, :is_privacy_policy_accepted])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    mypage_member_customers_path
  end
end

