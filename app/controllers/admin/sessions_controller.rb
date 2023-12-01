# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    flash[:notice] = I18n.t('devise.sessions.admin.signed_out') if signed_out
    yield if block_given?
    respond_to_on_destroy
  end

  private

  # ログアウト後のリダイレクト先
  def respond_to_on_destroy
    redirect_to new_admin_session_path
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admin_members_path
    else
      super
    end
  end
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
