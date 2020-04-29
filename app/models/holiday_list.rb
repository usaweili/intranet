class HolidayList
  include Mongoid::Document
  field :holiday_date, type: Date
  field :reason, type: String
  field :country, type: String

  validates :holiday_date, :reason, :country, presence: true
  validate  :is_weekend?
  validate 'is_duplicate?("India")',  if: "country == 'India'"
  validate 'is_duplicate?("USA")',  if: "country == 'USA'"

  def self.is_holiday?(date, country_name)
    date.strftime("%A").eql?("Saturday") or
    date.strftime("%A").eql?("Sunday") or
    HolidayList.where(country: country_name).collect(&:holiday_date).include?(date)
  end

  def self.next_working_day(date, country_name)
    date = date + 1
    while HolidayList.is_holiday?(date, country_name)
      date = date.next
    end
    date
  end

  def is_weekend?
    if holiday_date.present?
      day = holiday_date.strftime("%A")
      if day.eql?('Saturday') || day.eql?('Sunday')
        errors.add(:holiday_date, 'cant create holiday on Saturday or Sunday')
      end
    end
  end

  def is_duplicate?(country_name)
    if holiday_date.present?
      if HolidayList.where(country: country_name).collect(&:holiday_date).include?(holiday_date)
        errors.add(:country, "Can't create duplicate holiday for #{country_name}")
      end
    end
  end
end
