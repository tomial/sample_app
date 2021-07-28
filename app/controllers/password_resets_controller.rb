class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def update
    # 未输入密码
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    # 更改密码成功
    elsif @user.update(user_params)
      @user.forget
      # 使token失效
      reset_session
      log_in @user
      @user.remove_reset_digest
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def edit; end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # 前置过滤器
  def get_user
    @user = User.find_by(email: params[:email])
    puts 'user:', @user
  end

  # 检查是否有效用户
  def valid_user
    unless @user&.activated? &&
           @user.authenticated?(:reset, params[:id])
      flash[:danger] = 'Password reset link has been used once' if @user.reset_digest.nil?
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired'
      redirect_to new_password_resets_path
    end
  end
end
