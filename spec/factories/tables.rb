# -*- coding: utf-8 -*-
FactoryBot.define do
    factory :table do
      sequence(:id)
      bib_id { nil }
      title { "great paper" }
    end
end