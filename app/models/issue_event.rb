class IssueEvent < Event
  validates :external_id, presence: true
end
