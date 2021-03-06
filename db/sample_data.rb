# Populate the database with a small set of realistic sample data so that as a developer/designer, you can use the
# application without having to create a bunch of stuff or pull down production data.
#
# After running db:sample_data, a developer/designer should be able to fire up the app, sign in, browse data and see
# examples of practically anything (interesting) that can happen in the system.
#
# It's a good idea to build this up along with the features; when you build a feature, make sure you can easily demo it
# after running db:sample_data.
#
# Data that is required by the application across all environments (i.e. reference data) should _not_ be included here.
# That belongs in seeds.rb instead.
#
puts "Creating sample data..."
begin
  ActiveRecord::Base.transaction do
    u1 = Identity::User.create!(email: "driver1@example.com", password: "password", is_driver: true)
    u2 = Identity::User.create!(email: "passenger2@example.com", password: "password")
    u3 = Identity::User.create!(email: "passenger3@example.com", password: "password")
    u4 = Identity::User.create!(email: "passenger4@example.com", password: "password")

    year_2015 = Time.zone.parse("2015-01-01")
    year_1995 = Time.zone.parse("1995-01-01")
    year_1985 = Time.zone.parse("1985-01-01")
    year_1955 = Time.zone.parse("1955-01-01")
    year_1935 = Time.zone.parse("1935-01-01")

    vehicle_type_default = Rideshare::VehicleType.create!(name: "delorean")
    vehicle_type_van = Rideshare::VehicleType.create!(name: "delorean-van")

    tier_default = Rideshare::ServiceTier.create!(rate: 5, vehicle_type: vehicle_type_default)
    tier_pool = Rideshare::ServiceTier.create!(rate: 2, vehicle_type: vehicle_type_default, is_eligible_for_trip_pooling: true)
    tier_xl = Rideshare::ServiceTier.create!(rate: 10, vehicle_type: vehicle_type_van)
    tier_eats = Rideshare::ServiceTier.create!(rate: 0, vehicle_type: vehicle_type_default)

    v1 = Rideshare::Vehicle.create!(user: u1, gigawatt_output_rating: 1.21, vehicle_type: vehicle_type_default)

    t1 = Rideshare::Trip.create!(origin_date: year_2015, destination_date: year_1985, driver: u1, passenger: u2, service_tier: tier_default)
    t2 = Rideshare::Trip.create!(origin_date: year_2015, destination_date: year_1955, driver: u1, passenger: u2, service_tier: tier_pool)
    t3 = Rideshare::Trip.create!(origin_date: year_1985, destination_date: year_1955, driver: u1, passenger: u3, service_tier: tier_pool)
    tpool = Rideshare::TripPool.create
    tpool.update(trips: [t2, t3])

    invoice1 = Financial::Invoice.create(user: u2, trip: t1, amount: 500)
    invoice2 = Financial::Invoice.create(user: u2, trip: t2, amount: 200)
    invoice3 = Financial::Invoice.create(user: u3, trip: t3, amount: 200)

    payment1 = Financial::Payment.create(invoice: invoice1, amount: 500)
    payment2 = Financial::Payment.create(invoice: invoice2, amount: 200)
    payment3 = Financial::Payment.create(invoice: invoice3, amount: 200)

    restaurant1 = FoodDelivery::Restaurant.create start_date: year_1985, end_date: year_1995, name: "Lizzie's Drive-Thru Burgers"
    restaurant2 = FoodDelivery::Restaurant.create start_date: year_1935, name: "McDonald's"

    menu1 = FoodDelivery::Menu.create(start_date: year_1985, restaurant: restaurant1, name: 'Lizzie')
    menu2 = FoodDelivery::Menu.create(start_date: year_1935, end_date: year_1955, restaurant: restaurant2, name: "McDonalds' Original FoodDelivery::Menu")
    menu3 = FoodDelivery::Menu.create(start_date: year_1955, end_date: year_1995, restaurant: restaurant2, name: "McDonalds' Updated FoodDelivery::Menu")

    menu_item1 = FoodDelivery::MenuItem.create(name: "Cheeseburger", menu: menu1, price: 3)
    menu_item2 = FoodDelivery::MenuItem.create(name: "McCheeseburger", menu: menu2, price: 30)
    menu_item3 = FoodDelivery::MenuItem.create(name: "Big Mac", menu: menu3, price: 300)

    Financial::InflationAdjustment.create(percent_change: 1.1, date: year_1955)
    Financial::InflationAdjustment.create(percent_change: 5.2, date: year_1985)
    Financial::InflationAdjustment.create(percent_change: 10.2, date: year_1995)
    Financial::InflationAdjustment.create(percent_change: 9.2, date: year_2015)

    o1 = FoodDelivery::Order.create(user: u4, menu_items: [menu_item1])
    t_eats = Rideshare::Trip.create(driver: u1, passenger: nil, order: o1, service_tier: tier_eats, origin_date: year_2015, destination_date: year_1985)

    puts "Finished creating sample data."
  end
rescue Exception => e
  puts "I found an error. Aborting..."
  puts e.inspect
end

