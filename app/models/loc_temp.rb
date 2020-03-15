class LocTemp < ApplicationRecord
  validates :loc_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :temperature, presence: true

  scope :filter_by_location, ->(loc_ids) { where loc_id: loc_ids} #and today - created_at convert to date >0
end
