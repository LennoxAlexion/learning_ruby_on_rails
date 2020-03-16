class LocTemp < ApplicationRecord
  validates :loc_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :temperature, presence: true

  scope :filter_by_location, ->(loc_ids, from_date) { select('loc_id, temperature, date').where(loc_id: loc_ids).where('date >= ?', from_date).order(date: :asc) }
end
