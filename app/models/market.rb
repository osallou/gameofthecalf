class Market < ActiveRecord::Base
  attr_accessible :animal, :group_id, :owner, :status, :values

  has_many :bids, :dependent => :nullify

  # New level status
  STATUS_CLOSED = 0
  # open to proposals
  STATUS_OPEN = 1
  # bids in progress
  STATUS_BIDS = 2

  ANIMAL_PROPOSED = 0
  ANIMAL_SELECTED = 1

end
