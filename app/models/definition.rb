class Definition < ApplicationRecord
  belongs_to :word
  validates :word_id, presence: true
  validates :content, presence: true, length: {maximum: 1000}
end
