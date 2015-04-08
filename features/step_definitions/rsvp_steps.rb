Given(/^the following guests exist:$/) do |guests_table|
  guests_table.hashes.each do |guest|
    Guest.create!(guest)
  end
end

Given(/^the following registrations exist:$/) do |registrations_table|
  registrations_table.hashes.each do |registration|
    Registration.create!(registration)
  end
end

When(/^I fill out and submit the RSVP form with email "(.*)"$/) do |email|
  fill_in('guest_first_name', :with => 'Jonathan')
  fill_in('guest_last_name', :with => 'Smith')
  fill_in('guest_phone', :with => '956-865-1475')
  fill_in('guest_email', :with => email)
  fill_in('guest_address', :with => '12 Place Blvd.')
  choose('guest_is_anon_false')
  click_button('Submit')
end

Then(/^I should see attendees of "(.*)" listed alphabetically by first name$/) do |event_name|
  event = Event.find_by_name(event_name)
  ordered_non_anon_guests = event.guests.where(is_anon: false).order(:first_name)

  prev_guest = nil
  ordered_non_anon_guests.each do |guest|
    if (prev_guest != nil) && (prev_guest != '')
      puts "prev_guest is: " + prev_guest.first_name
      puts "guest is: " + guest.first_name
      puts page.body.match(/<td>#{prev_guest.first_name}<\/td>(.*)<td>#{guest.first_name}<\/td>/m)
      expect(page).to have_content(/#{prev_guest.first_name}(.*)#{guest.first_name}/)
    end
    prev_guest = guest
  end
end


Then(/^I should not see anonymous attendees of "(.*)"$/) do |event_name|
  event = Event.find_by_name(event_name)
  anon_guests = event.guests.where(is_anon: true)
  anon_guests.each do |guest|
    step %{the page should not have the text "#{guest.first_name} #{guest.last_name}"}
  end
end

Then(/^I should see the RSVP form$/) do
  tags = ['guest_first_name', 'guest_last_name', 'guest_phone', 'guest_email',
          'guest_address', 'guest_is_anon_true', 'guest_is_anon_false']
  tags.each do |tag|
    expect(page).to have_css("##{tag}")
  end
end

When(/^I fill out and submit the RSVP form (anonymously|non-anonymously)$/) do |anon|
  fill_in('guest_first_name', :with => 'Alexander')
  fill_in('guest_last_name', :with => 'Hamilton')
  fill_in('guest_phone', :with => '956-975-1475')
  fill_in('guest_email', :with => 'aHamil@usa.com')
  fill_in('guest_address', :with => '12 New England Blvd')
  if anon == 'anonymously'
    choose('guest_is_anon_true')
  else
    choose('guest_is_anon_false')
  end
  click_button('Submit')
end

Then(/^I should see a message confirming my submission$/) do
  step %{the page should have the text "You successfully registered for this event!"}
end

Then(/^I should( not)? see my first name on the page$/) do |should_not|
  if should_not
    step %{the page should not have the text "Alexander"}
  else
    step %{the page should have the text "Alexander"}
  end
end

When(/^I do not fill out the entire RSVP form$/) do
  fill_in('guest_first_name', :with => 'Alexander')
  fill_in('guest_last_name', :with => 'Hamilton')
end

When(/^I press "(.*)"$/) do |button|
  click_button(button)
end

Then(/^I should see a failed submission message$/) do
  step %{the page should have the text "Please fill out all fields to RSVP."}
end

Then(/^the page should( not)? have the text "(.*)"$/) do |should_not, text|
  if should_not
    expect(page).to have_no_content(text)
  else
    expect(page).to have_content(text)
  end
end

Then(/^I should see a message saying that the email "(.*)" is already registered$/) do |email|
  step %{the page should have the text "#{email} is already registered for this event!"}
end
