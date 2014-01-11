class UsersController < ApplicationController
  
  def create
    @user = User.new(user_params)   # not final implementation
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      flash[:error] = "There was a problem signing you up."
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if(@user.update_attributes(user_params))
      # success
    else
      # failure
      flash.now[:error] = "Could not update profile"
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user)
            .permit(:name, 
                    :email,
                    :password,
                    :password_confirmation)
    end

end
