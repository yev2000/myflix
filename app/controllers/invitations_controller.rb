class InvitationsController < ApplicationController
  before_action :require_user, only: [:new, :create]
  before_action :set_invitation, only: [:show]

  def new
    @invitation = Invitation.new
    @invitation.message = "Please join this really cool site!"
  end

  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.user = current_user
    @invitation.token = SecureRandom.urlsafe_base64
    if (@invitation.save)
      AppMailer.notify_invitation(@invitation).deliver
      flash[:success] = "We have sent an invitation to #{@invitation.email}.  Thank you!"
      redirect_to home_path
    else
      render :new
    end
  end

  def show
    @user = User.new
    @user.email = @invitation.email
    @user.fullname = @invitation.fullname
    render "users/new"
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :fullname, :message, :user_id)
  end

  def set_invitation
    @invitation = Invitation.find_by_token(params[:id])
    if @invitation.nil? 
      flash[:danger] = "Your invitation has expired or is not valid." 
      redirect_to sign_in_path
    end
  end

end
