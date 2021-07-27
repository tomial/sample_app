class UsersController < ApplicationController

  # 判断是否登陆
  before_action :logged_in_user, only: %i[index edit update destroy]
  # 判断访问的是否当前用户页面
  before_action :correct_user, only: %i[edit update]
  # 删除前判断是否管理员
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Welcome to the sample app'
      reset_session
      log_in(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
      # 处理更新成功的情况
    else
      render 'edit'
    end
  end

  # 判断是否登陆，否则提示并跳转到登陆页面
  def logged_in_user
    unless logged_in?
      # 存储登陆前的地址，登陆成功后用于跳转
      store_location
      flash[:danger] = 'Please log in'
      redirect_to login_url
    end
  end

  private

  # 判断访问的是否当前登陆用户的页面，否则跳转到主页
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
