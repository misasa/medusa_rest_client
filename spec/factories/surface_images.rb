# -*- coding: utf-8 -*-
FactoryBot.define do
    factory :surface_image do
      sequence(:id)
      surface_id { nil }
      image_id { nil }
    end
end