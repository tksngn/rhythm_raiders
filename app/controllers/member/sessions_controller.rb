# frozen_string_literal: true

class Member::SessionsController < Devise::SessionsController
  # prepend_before_action :require_no_authentication, only: [:new, :create]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   self.resource = warden.authenticate!(auth_options)
  #   if self.resource
  #     set_flash_message!(:notice, :signed_in)
  #     sign_in(resource_name, resource)
  #     respond_with resource, location: after_sign_in_path_for(resource)
  #   else
  #     # flash[:alert] = I18n.t("member.devise.failure.invalid", authentication_keys: "email")
  #     redirect_to new_member_session_path
  #   end
  # end

  # DELETE /resource/sign_out
#   def destroy
#     signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
# =begin
#     if signed_out
#       flash[:notice] = I18n.t('member.devise.sessions.member.signed_out')
#     else
#       flash[:notice] = I18n.t('member.devise.failure.already_signed_out')
#     end
# =end
#     yield if block_given?
#     respond_to_on_destroy
#   end

  def guest_sign_in
    member = Member.guest
    sign_in member
    redirect_to root_path, notice: 'ゲストメンバーとしてログインしました。'
  end

  def after_sign_in_path_for(resource)
    mypage_member_customers_path
  end
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

end
