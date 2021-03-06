class TicketsController < ApplicationController
  before_action :require_user, except: [:index, :show]

  def index
    @project = params[:project]
    @status = params[:status]
    @tickets = filter_tickets(@project, @status) 

    filter_by_tag if params[:tag]
  end

  def show
    @ticket = Ticket.find(params[:id])
    @comment = Comment.new
    @comments = Comment.all.where ticket_id: @ticket.id
    @users = User.all
  end

  def new
    unless Project.any?
      flash[:notice] = "Must create project before creating a ticket"
      redirect_to root_path
    end

    @ticket = Ticket.new
    @projects = Project.all
    @tags = Tag.all
    @users = User.all
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      flash[:success] = "Created ticket"
      redirect_to project_path(Project.find(params[:ticket][:project_id]))
    else
      render :new
    end
  end

  def edit
    @tags = Tag.all
    @users = User.all
    @projects = Project.all
    @ticket = Ticket.find(params[:id])
    @currentTagIds = @ticket.tags.ids
  end

  def update
    @ticket = Ticket.find(params[:id])

    if @ticket.update(ticket_params)
      flash[:success] = "Ticket updated"
      redirect_to project_path(@ticket.project_id)
    else
      render :edit
    end
  end

  def destroy
    Ticket.destroy(params[:id])
    flash[:success] = "Ticket successfully destroy"
    redirect_to root_path
  end

  private

  def filter_tickets(project, status)
    tickets = Ticket.all
    tickets = tickets.where({ project_id: project.to_i }) if project && !project.empty?
    tickets = tickets.where({ status: status }) if status && !status.empty?
    tickets
  end

  def filter_by_tag
    ticket_tags = TicketTag.where(tag_id: params[:tag]).map { |tt| tt.ticket_id}
    @tickets = @tickets.select { |ticket| ticket_tags.include? ticket.id}
  end

  def ticket_params
    params.require(:ticket).permit(:name, :body, :status, :project_id, :assignee, tag_ids: []).merge(creator: session[:user_id])
  end
end