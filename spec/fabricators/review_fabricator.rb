Fabricator(:review) do
  title { Faker::Lorem.sentence(5) }
  body { Faker::Lorem.paragraph(3) }
  rating { rand(0..5) }
end
