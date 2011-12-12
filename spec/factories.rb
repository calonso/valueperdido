
Factory.define :user do |user|
  user.name                   "Carlos"
  user.surname                "Alonso Perez"
  user.email                  "valueperdido@gmail.com"
  user.password               "ThePassw0rd"
  user.password_confirmation  "ThePassw0rd"
end

Factory.sequence :name do |n|
  "User #{n}"
end

Factory.sequence :email do |n|
  "user-#{n}@example.org"
end
