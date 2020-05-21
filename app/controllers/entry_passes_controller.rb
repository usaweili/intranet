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
      redirect_to entry_passes_path
    else
      render 'index'
    end
  end

  private

  def entry_pass_params
    params.require(:entry_pass).permit(:date, :user_id)
  end

end
