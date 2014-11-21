Fabricator(:user) do
  email { Faker::Internet.email }
  fullname { Faker::Name.name }
  password { Faker::Lorem.characters(6) }
  admin false
end

Fabricator(:admin, from: :user) do
  admin true
end