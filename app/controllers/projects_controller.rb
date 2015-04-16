class ProjectsController < ApplicationController
  before_action :check_membership, only: [:edit, :update, ]
  before_filter :authorize, only: [:index, :show]

  def index
    @projects = current_user.projects
  end

  def show
    @project = Project.find(params[:id])
    unless @project.users.include? current_user
        redirect_to projects_path, alert: "You do not have access to that project"
    end
    # @membership = Membership.where(user_id: current_user.id)[0]
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to project_tasks_path(@project), notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
    @membership = Membership.create(project_id: @project.id, user_id: current_user.id, role: 1)
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    unless @project.users.include? current_user
        redirect_to projects_path, alert: "You do not have access to that project"
    end
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted'
  end


  private
  def project_params
    params.require(:project).permit(:name)
  end

  def owner
    unless @project.users.include? current_user
        redirect_to projects_path, alert: "You do not have access to that project"
    end
  end


  def check_membership
    @membership = Membership.where(user_id: current_user.id)[0]
    unless @membership.role == 'owner'
      redirect_to projects_path, alert: "You do not have access to that project"
    end
  end
end
