class EntryPassesController < ApplicationController
  def index
    @office_passes = EntryPass.where(date: Date.today..Date.today+7).group_by{|entry_pass| entry_pass.date}
    @entry_passes = if current_user.entry_passes.where(:date.gte => Date.today).count > 0
      current_user.entry_passes.where(:date.gte => Date.today)
    else
      current_user.entry_passes.build
    end
    @user = current_user
  end

  def new
    @user = current_user
  end

  def create
    current_user.attributes = {'entry_passes_attributes' => entry_pass_params}
    if current_user.valid? && current_user.save!
      flash[:success] = "Entry Pass Created Succesfully"
    else
      @office_passes = EntryPass.where(date: Date.today..Date.today+7).group_by{|entry_pass| entry_pass.date}
      flash[:error] = "Error while creating entry passes, please try again."
      @error = true
    end
  end

  def report
    @report_date = report_params[:date]
    @entry_passes = EntryPass.where(date: @report_date)
    respond_to do |format|
      format.csv do
        send_data EntryPass.to_csv(@entry_passes), filename: "Office_entries_#{@report_date}.csv"
      end
    end
  end

  def destroy
    @entry_pass = EntryPass.where({id: params[:id]}).first
    user_id = @entry_pass.user_id
    @entry_pass.destroy
    flash[:success] = "Entry Pass deleted succesfully"
    if user_id == current_user.id
      redirect_to '/office_pass'
    else
      redirect_to entry_passes_path
    end
  end

  private

  def entry_pass_params
    params[:user].require(:entry_passes_attributes).permit!
  end

  def report_params
    params.permit(:date)
  end

end
