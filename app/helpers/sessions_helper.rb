module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id

    session[:session_token] = user.session_token
  end

  # 记住我
  def remember(user)
    # 在数据库中添加remember_digest摘要
    user.remember

    # 在cookie中设置加密的user_id和完整的remember_token
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 获取当前登陆用户
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user&.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 判断user是否当前登陆用户
  def current_user?(user)
    user&.==current_user
  end

  # 清除用户cookie中"记住我"的信息
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # 存储地址用于友好跳转
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
