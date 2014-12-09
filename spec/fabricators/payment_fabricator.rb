Fabricator(:payment) do
  amount { rand(500..999) }
  stripe_event_id { Faker::Lorem.characters(15) }
  reference_id { Faker::Lorem.characters(15) }
end
