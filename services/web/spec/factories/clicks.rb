FactoryBot.define do
  factory :click do
    device_type { 'rfid' }
    sequence(:device_id) { |n| "rfid:#{n}" }
    useful { false }
  end
end
