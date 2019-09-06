class HolidayListsController < ApplicationController

  before_action :load_holiday, only: [:update, :edit, :destroy]

  def index
    @holiday = HolidayList.where(
      holiday_date:Date.today.at_beginning_of_year..Date.today.at_end_of_year).
      order(holiday_date: :asc
    )
  
  end

  def create
    @holiday = HolidayList.new(holiday_params)
    if @holiday.valid?
      @holiday.save
      flash[:success] = "Holiday created Succesfully"
      redirect_to new_holiday_list_path
    else
      render 'new'
    end
  end

  def new
    @holiday = HolidayList.new
  end

  def edit
  end

  def update
    if @holiday.update(holiday_params)
      flash[:success] = 'Holiday updated Succesfully'
      redirect_to holiday_lists_path
    end
  end

  def destroy
    if @holiday.destroy
      flash[:success] = 'Holiday deleted Succesfully'
      redirect_to holiday_lists_path
    end
  end

  def holiday_list
    holiday = HolidayList.where(
      holiday_date:Date.today.at_beginning_of_year..Date.today.at_end_of_year).
      order(holiday_date: :asc)
    render json: holiday 
  end


  private

  def holiday_params
    params.require(:holiday_list).permit(:holiday_date,:reason)
  end

  def load_holiday
    @holiday = HolidayList.find(params[:id])
  end
end
