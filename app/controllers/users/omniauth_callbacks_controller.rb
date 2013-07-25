class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Allows us to mock util for tests
  @@util_save_picture = Util.method(:save_picture)

  def get_expiration(auth)
    if not auth['credentials']['expires'].nil? and not auth['credentials']['expires']
      expiration_date = Time.now().advance(:years => 100).to_datetime
    else
      expiration_date = Time.at(auth['credentials']['expires_at']).to_datetime
    end

    expiration_date
  end

  def facebook
    auth = request.env["omniauth.auth"]

    @user = User.where(:provider => auth.provider, :uid => auth.uid).first

    if @user.nil?
      # The user came from the signup flow
      if params[:state] == "signup"
        # User is new, continue flow

        # Get user profile picture
        profile_pic_name = @@util_save_picture.call(auth['info']['image'])

        # Create user's account
        @user = User.create(
            name:auth['info']['name'],
            profile_pic:profile_pic_name,
            provider:auth.provider,
            uid:auth.uid,
            email:auth['info']['email'],
            password:Devise.friendly_token[0,20],
            token:auth['credentials']['token'],
            token_expiration:get_expiration(auth))

        sign_in @user
        redirect_to "/facebook_tab_app/load_account"
      else
        redirect_to :root
      end
    else
      # Sign user in and refresh Facebook token
      sign_in @user

      @user.update_attributes!(
          :token => auth['credentials']['token'],
          :token_expiration => get_expiration(auth))

      # Redirect to done if the user is in the signup flow
      if params[:state] == "signup"
        redirect_to "/facebook_tab_app/done"
      else
        redirect_to :root
      end
    end
  end
end
