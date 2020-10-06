class HolidayList
  include Mongoid::Document
  field :holiday_date, type: Date
  field :reason, type: String
  field :country, type: String

  validates :holiday_date, :reason, :country, presence: true
  validate :check_weekend?
  validate :check_duplicate?

  def self.is_holiday?(date, country_name)
    is_weekend?(date) ||
    HolidayList.where(country: country_name).collect(&:holiday_date).include?(date)
  end

  def self.is_weekend?(date)
    date.strftime("%A").eql?('Saturday') ||
    date.strftime("%A").eql?('Sunday')
  end

  def self.next_working_day(date, country_name)
    date = date + 1
    while HolidayList.is_holiday?(date, country_name)
      date = date.next
    end
    date
  end

  def check_weekend?
    if HolidayList.is_weekend?(holiday_date)
      errors.add(:holiday_date, 'cant create holiday on Saturday or Sunday')
    end
  end

  def check_duplicate?
    if holiday_date_changed? || country_changed?
      if HolidayList.where(country: country).collect(&:holiday_date).include?(holiday_date)
        errors.add(:country, "Can't create duplicate holiday for #{country}")
      end
    end
  end
end
