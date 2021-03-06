module SessionsHelper

  def login(user)
    cookies.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def current_user?(user)
    user == current_user
  end

  def logout
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def authenticate
    deny_access unless logged_in?
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def deny_access
    store_location
    redirect_to login_path, :notice => "Please login to access this page."
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_stored_location
  end

  private

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_stored_location
      session[:return_to] = nil
    end

    def user_from_remember_token
      User.auth_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

end
