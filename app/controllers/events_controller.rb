class EventsController < ApplicationController

  before_filter :authenticate
  before_filter :admin_user, :only => [ :new, :create, :edit, :update, :destroy]

  def index
    @events = Event.active_events
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(params[:event])
    if @event.save
      flash[:success] = "Event successfully created!"
      redirect_to events_path
    else
      render 'new'
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @title = "Edit event"
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:success] = "Event successfully updated."
      redirect_to @event
    else
      @title = "Edit event"
      render 'edit'
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    flash[:success] = "Event destroyed"
    redirect_to events_path
  end
end
