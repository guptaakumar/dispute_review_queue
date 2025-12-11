# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
    # The sign-in page and action must be accessible without a current session
    skip_before_action :authenticate_user!, only: [:new, :create]
  
    # GET /sign_in
    def new
      # Render the sign-in form (app/views/sessions/new.html.erb)
    end
  
    # POST /sessions (Sign In)
    def create
      user = User.find_by(email: params[:email])
  
      if user && user.authenticate(params[:password])
        # Successful authentication
        session[:user_id] = user.id
        redirect_to root_path, notice: "Signed in successfully as #{user.role}."
      else
        # Failed authentication
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unauthorized
      end
    end
  
    # DELETE /sign_out
    def destroy
      session[:user_id] = nil
      redirect_to sign_in_path, notice: "You have been signed out."
    end
end
