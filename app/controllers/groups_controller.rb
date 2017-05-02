class GroupsController < ApplicationController
before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join, :quit]
before_action :find_group_and_check_permission, only: [:edit, :update, :destroy]

def index
  @groups = Group.all
  @groups = @groups.paginate(:page => params[:page], :per_page => 5)
end

def new
  @group = Group.new
end

def create
  @group = Group.new(group_params)
  @group.user = current_user
   if @group.save
     current_user.join(@group)
  redirect_to groups_path
else
  render :new
end
end

def edit
end

def update

  if @group.update(group_params)
  redirect_to groups_path, notice: "update success"
else
  render :edit
  end
end

def show
  @group = Group.find(params[:id])
  @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
end

def destroy
  @group.destroy
  flash[:alert] = "group delete"

end

def join
  @group = Group.find(params[:id])

  if !current_user.is_member_of?(@group)
    current_user.join!(@group)
    flash[:notice] = "Success to join"
  else
    flash[:warning] = "You have been the member~"
  end
  redirect_to group_path(@group)
end

def quit
  @group = Group.find(params[:id])

  if current_user.is_member_of?(@group)
    current_user.quit!(@group)
    flash[:notice] = "Quit the group"
  else
    flash[:warning] = "You don't have need to to quit~"
  end
  redirect_to group_path(@group)
end


private

def group_params
  params.require(:group).permit(:title, :description)
end

def find_group_and_check_permission
  @group = Group.find(params[:id])

  if current_user !=@group.user
    redirect_to root_path, alert: "you have no permission"
  end
end

end
