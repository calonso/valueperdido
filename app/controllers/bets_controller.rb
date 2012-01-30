class BetsController < ApplicationController
  before_filter :authenticate
  before_filter :more_bets_allowed, :only => [:new, :create]
  before_filter :admin_user, :only => [:edit, :update]
  before_filter :owner, :only => :destroy

  def index
    @event = Event.find(params[:event_id])
    @bets = Bet.with_votes_for_event(params[:event_id], current_user.id)
  end

  def new
    @event = Event.find(params[:event_id])
    @bet = Bet.new
  end

  def create
    @bet = current_user.bets.build(params[:bet])
    @bet.event_id = params[:event_id]
    if @bet.save
      flash[:success] = t :bet_created_flash
      redirect_to event_bets_path, :event_id => params[:event_id]
    else
      render 'new'
    end
  end

  def event_user_bets
    @event = Event.find(params[:event_id])
    @bets = Bet.where("user_id = ? AND event_id = ?", current_user, params[:event_id])
  end

  def vote
    bet = Bet.find(params[:id])
    attrs = { :event => bet.event, :bet => bet }
    vote = current_user.votes.build(attrs)
    if vote.save
      flash[:success] = t :bet_voted_flash
    else
      flash[:error] = t :bet_voted_flash_err
    end
    redirect_to event_bets_path, :event_id => params[:event_id]
  end

  def unvote
    votes = Vote.where("bet_id = ? AND user_id = ?", params[:id], current_user.id)
    if votes.count > 0
      votes.each do |vote|
        vote.destroy
      end
      flash[:success] = t :vote_deleted_flash
    else
      flash[:error] = t :vote_deleted_flash_err
    end
    redirect_to event_bets_path, :event_id => params[:event_id]
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
      flash[:success] = t :bet_updated_flash
      redirect_to event_bet_path, :event_id => params[:event_id], :bet => @bet
    else
      render 'edit'
    end
  end

  def destroy
    Bet.find(params[:id]).destroy
    flash[:success] = t :bet_deleted_flash
    redirect_to event_user_bets_path, :event_id => params[:event_id]
  end

  private

    def more_bets_allowed
      bets = Bet.where("user_id = ? AND event_id = ?", current_user, params[:event_id])
      if bets.count >= Valueperdido::Application.config.max_bets_per_user
        flash[:notice] = t :max_bets_err
        redirect_to event_user_bets_path, :event_id => params[:event_id]
      end
    end

    def owner
      bet = Bet.find(params[:id])
      redirect_to root_path unless current_user?(bet.user)
    end

end
