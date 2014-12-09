require 'rails_helper'

feature "admin payments table" do
  background do
    @admin_user = Fabricate(:admin)
    alice = Fabricate(:user, email: "alice@aaa.com", stripe_customer_id: "token1")
    bob = Fabricate(:user, email: "bob@bbb.com", stripe_customer_id: "token2")
    charlie = Fabricate(:user, email: "charlie@ccc.com", stripe_customer_id: "token3")

    @alice_payment = Fabricate(:payment, user: alice)
    @bob_payment = Fabricate(:payment, user: bob)
    @charlie_payment = Fabricate(:payment, user: charlie)
  end

  scenario "admin views payments table" do
    # first log in
    sign_in_user(@admin_user)
    expect_user_name_on_page(@admin_user)
    
    click_link "Add Video"
    expect(page).to have_content "Add a New Video"
    click_link "Recent Payments"
    expect(page).to have_content "Reference ID"

    # we expect to see at table of payments here
    expect_payments_table([@alice_payment, @bob_payment, @charlie_payment]) 
  end
end

def expect_payments_table(payments_existing)
  payments_existing.each do |payment|
    expect(page).to have_xpath("//tr[contains(.,'#{payment.user.email}')]//td[contains(., '#{payment.decorate.charge_amount_string}')]")
  end
end
