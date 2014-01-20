class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:edit, :index, :update, :destroy]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: [:destroy]

  # POST /users
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

  # DELETE /users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User #{params[:id]} deleted"
    redirect_to users_url
  end

  # GET /users/:id/edit
  def edit
    # @user = User.find(params[:id])    # provided in before action, correct_user
  end

  def index
    page = params[:page].blank? ? 1 : params[:page]
    @users = User.paginate(page: page)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  # PUT/PATCH /users/:id
  def update
    # @user = User.find(params[:id])     # provided in before action, correct_user
    if(@user.update_attributes(user_params))
      # success
      flash[:success] = "Profile successfully updated."
      redirect_to @user
    else
      # failure
      flash.now[:error] = "Could not update profile."
      render 'edit'
    end
  end

  # GET     /users        -> index
  # DELETE  /users/:id    -> destroy

  private

    def user_params
      params.require(:user)
            .permit(:name, 
                    :email,
                    :password,
                    :password_confirmation)
      # DO NOT include :admin here, protected field
    end

    # before filters
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end

      # equivalent implementation
      #
      # unless signed_in?
      #   flash[:notice] = "Please sign in."    # does not work for :error, :success
      #   redirect_to signin_url
      # end
    end

end
