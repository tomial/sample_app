class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  # 判断是否登陆，否则提示并跳转到登陆页面
  def logged_in_user
    unless logged_in?
      # 存储登陆前的地址，登陆成功后用于跳转
      store_location
      flash[:danger] = 'Please log in'
      redirect_to login_url
    end
  end
end
