class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show update destroy ]
  skip_before_action :authorized, only: [ :create ]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  def me
    render json: current_user, status: :ok
  end

  # POST /users
  def create
    puts params.inspect
    puts user_params.inspect

    @user = User.create!(
      username: user_params[:username],
      password: user_params[:password],
      first_name: user_params[:first_name],
      middle_name: user_params[:middle_name],
      last_name: user_params[:last_name]
    )
    @token = encode_token(user_id: @user.id)

    if @user.save
      render json: @user, status: :created, location: @user, token: @token
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :password, :first_name, :middle_name, :last_name)
    end

    def handle_invalid_record(e)
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
end
