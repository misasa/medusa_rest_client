FactoryBot.define do
  factory :specimen do
    sequence(:id)
    name { "specimen １" }
    specimen_type { "サンプル１" }
    description { "説明１" }
    parent_id { "" }
#    association :place, factory: :place
#    association :box, factory: :box
#    association :physical_form, factory: :physical_form
#    association :classification, factory: :classification
    quantity { 1 }
    quantity_unit { "数量単位１" }
  end
end