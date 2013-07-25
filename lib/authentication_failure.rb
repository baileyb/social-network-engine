class AuthenticationFailure < Devise::FailureApp
  protected

  def redirect_url
    "/users/sign_in"
  end

end