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
    @current_user_passes = EntryPass.where({user_id: current_user.id, date:{"$gte": Date.today}}).sort_by{|entry_pass| entry_pass.date}
  end

  def report
    @report_date = report_params[:download_date]
    @entry_passes = EntryPass.where(date: @report_date)
    respond_to do |format|
      format.csv do
        send_data @entry_passes.to_csv, filename: "Office_entries_#{@report_date}.csv"
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
    params.require(:entry_pass).permit(:date, :user_id)
  end

  def report_params
    params.permit(:download_date)
  end

end
