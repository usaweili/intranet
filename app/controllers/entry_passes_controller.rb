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
    old_passes_ids = current_user.entry_passes.pluck(:id)
    current_user.attributes = {'entry_passes_attributes' => entry_pass_params}
    if current_user.valid? && current_user.save!
      flash[:success] = "Entry Pass Created Succesfully"
      entry_passes_ids = current_user.entry_passes.pluck(:id)
      if (entry_passes_ids - old_passes_ids).count > 0
        UserMailer.delay.new_entry_passes(entry_passes_ids)
      end
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
    date = @entry_pass.date
    @entry_pass.destroy
    flash[:success] = "Entry Pass deleted succesfully"
    if user_id != current_user.id
      deleted_by = current_user.id
      UserMailer.delay.delete_office_pass(date, user_id, deleted_by)
    end
    redirect_to entry_passes_path
  end

  private

  def entry_pass_params
    params[:user].require(:entry_passes_attributes).permit!
  end

  def report_params
    params.permit(:date)
  end

end
