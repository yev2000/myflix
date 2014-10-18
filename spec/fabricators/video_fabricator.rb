Fabricator(:video) do
  title { Faker::Lorem.words(4).join(" ") }
  description { Faker::Lorem.paragraph(2) }
end
