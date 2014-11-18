Fabricator(:invitation) do
  email { Faker::Internet.email }
  fullname { Faker::Name.name }
  token { SecureRandom.urlsafe_base64 }
end
