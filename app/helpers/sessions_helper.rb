module SessionsHelper


  # def assignment of User.current_user
  #
  def current_user=(user)
    @current_user = user
  end

  # boolean method to check if current user
  #
  def current_user?(user)
    user == current_user
  end

  # def retrieving current_user value
  # memoization only useful if hit more than once per page
  # find_by is called at least once per page
  #
  def current_user
    # @current_user     # useless, same as Rails attr_acessor
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token       # same as 20 year cookie
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  # Setting a new cookie for the current user in the db will invalidate cookie at signout
  # this is to prevent a stolen cookie to remain valid. Setting current_user to nil is no
  # required as it comes for free with rediect, but it is not good to rely on this
  #
  def sign_out
    current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def signed_in?
    !current_user.nil?
  end

end
