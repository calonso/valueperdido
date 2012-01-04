
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

Factory.define :event do |event|
  event.name        "Event name"
  event.date        Date.today
  event.association :user
end

Factory.define :bet do |bet|
  bet.description   "The bet's description"
  bet.association   :user
  bet.association   :event
end
