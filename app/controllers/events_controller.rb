class EventsController < ApplicationController
  before_filter :authenticate
  before_filter :admin_user, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @closing_events = Event.closing_events
    @events = Event.active_events.paginate(:page => params[:page])
    @running_events = Event.running_events
  end

  def history
    @events = Event.past_events.paginate(:page => params[:page])
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(params[:event])
    if @event.save
      flash[:success] = t :event_created_flash
      redirect_to events_path
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:success] = t :event_updated_flash
      redirect_to @event
    else
      render 'edit'
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    flash[:success] = t :event_destroyed_flash
    redirect_to events_path
  end
end
