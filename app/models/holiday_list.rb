class HolidayList
  include Mongoid::Document
  field :holiday_date, type: Date
  field :reason, type: String

  validates :holiday_date, :reason, presence: true
  validates :holiday_date, uniqueness: true
  validate  :is_weekend?

  def self.is_holiday?(date)
    date.strftime("%A").eql?("Saturday") or date.strftime("%A").eql?("Sunday") or
      HolidayList.all.collect(&:holiday_date).include?(date)
  end

  def self.next_working_day(date)
    date = date + 1
    while HolidayList.is_holiday?(date)
      date = date.next
    end
    date
  end

  def is_weekend?
    day = holiday_date.strftime("%A")
    if day.eql?('Saturday') || day.eql?('Sunday')
      errors.add(:holiday_date, 'cant create holiday on Saturday or Sunday')
    end
  end

end
