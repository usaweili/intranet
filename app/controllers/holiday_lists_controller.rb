class HolidayListsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :load_holiday, only: [:update, :edit, :destroy]
  attr_accessor :holiday

  def index
    @year = params[:year].present? ? params[:year].to_i : Date.today.year
    date  = Date.new(@year)
    @holidays = HolidayList.where(holiday_date: date..date.at_end_of_year)
                           .order(holiday_date: :asc)
  end

  def create
    @holiday = HolidayList.new(holiday_params)
    if @holiday.valid?
      @holiday.save
      flash[:success] = "Holiday Created Successfully"
      redirect_to new_holiday_list_path
    else
      flash[:error] = "Can't Create Holiday"
      render 'new'
    end
  end

  def new
    @holiday = HolidayList.new
  end

  def edit
  end

  def update
    if @holiday.update_attributes(holiday_params)
      flash[:success] = 'Holiday Updated Successfully'
      redirect_to holiday_lists_path
    else
      flash[:error] = "Can't update Holiday"
      render 'new'
    end
  end

  def destroy
    if @holiday.destroy
      flash[:success] = 'Holiday Deleted Successfully'
    else
      flash[:error] = "Can't Delete Holiday"
    end
    redirect_to holiday_lists_path
  end

  def holiday_list
    date = Date.today.at_beginning_of_year
    if params['location'].nil?
      holiday = HolidayList.where(:holiday_date.gte => date)
    else
      user_country = current_user.country
      holiday = HolidayList.where(:holiday_date.gte => date, country: user_country)
    end
    render json: holiday
  end

  private

  def holiday_params
    params.require(:holiday_list).permit(:holiday_date, :holiday_type, :reason, :country)
  end

  def load_holiday
    @holiday = HolidayList.find(params[:id])
  end
end
