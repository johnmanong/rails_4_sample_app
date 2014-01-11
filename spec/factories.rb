FactoryGirl.define do
  factory :user do
    name                  "John Doe"
    email                 "john@theinter.net"
    password              "foobar"
    password_confirmation "foobar"
  end
end