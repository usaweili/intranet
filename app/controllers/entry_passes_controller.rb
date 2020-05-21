class EntryPassesController < ApplicationController
  def index
    @office_passes = EntryPass.all.sort_by{|entry_pass| entry_pass.date}
    @entry_pass = EntryPass.new
  end

  def create
    @entry_pass = EntryPass.new(entry_pass_params)
    if @entry_pass.valid?
      @entry_pass.save
      flash[:success] = "Entry Pass Created Succesfully"
    else
      flash[:error] = @entry_pass.errors.full_messages.join(" ")
    end
    redirect_to entry_passes_path
  end

  def office_pass
    @entry_pass = EntryPass.new
    @current_user_passes = EntryPass.where({user_id: current_user.id}).sort_by{|entry_pass| entry_pass.date}
  end

  def destroy
    @entry_pass = EntryPass.where({id: params[:id]}).first
    @entry_pass.destroy
    flash[:success] = "Entry Pass deleted succesfully"
    redirect_to '/office_pass'
  end

  private

  def entry_pass_params
    params.require(:entry_pass).permit(:date, :user_id)
  end

end
