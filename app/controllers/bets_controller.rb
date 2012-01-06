class BetsController < ApplicationController
  before_filter :authenticate
  before_filter :more_bets_allowed, :only => [:new, :create]
  before_filter :admin_user,   :only => [:show, :edit, :update]
  before_filter :owner, :only => :destroy

  def index
    @bets = Bet.where(:event_id => params[:event_id]).paginate(:page => params[:page])
  end

  def new
    @event = Event.find(params[:event_id])
    @bet = Bet.new
  end

  def create
    @bet = current_user.bets.build(params[:bet])
    @bet.event_id = params[:event_id]
    if @bet.save
      flash[:success] = "Bet successfully created"
      redirect_to event_bets_path, :event_id => params[:event_id]
    else
      render 'new'
    end
  end

  def event_user_bets
    @bets = Bet.where("user_id = ? AND event_id = ?", current_user, params[:event_id])
  end

  def show
    @bet = Bet.find(params[:id])
  end

  def edit
    @bet = Bet.find(params[:id])
  end

  def update
    @bet = Bet.find(params[:id])
    if @bet.update_attributes(params[:bet])
      flash[:success] = "Bet successfully updated."
      redirect_to event_bet_path, :event_id => params[:event_id], :bet => @bet
    else
      render 'edit'
    end
  end

  def destroy
    Bet.find(params[:id]).destroy
    flash[:success] = "Bet successfully destroyed"
    redirect_to event_user_bets_path, :event_id => params[:event_id]
  end

  private

    def more_bets_allowed
      bets = Bet.where("user_id = ? AND event_id = ?", current_user, params[:event_id])
      if bets.count >= Valueperdido::Application.config.max_bets_per_user
        flash[:notice] = "Maximum bets for this event already created"
        redirect_to event_user_bets_path, :event_id => params[:event_id]
      end
    end

    def owner
      bet = Bet.find(params[:id])
      redirect_to root_path unless current_user?(bet.user)
    end

end
