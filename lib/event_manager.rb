require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def cleaned_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def cleaned_phone_number(phone_number)
  phone_array = phone_number.split('')
  phone_array = phone_array.select { |num| /\d/.match?(num) }

  if phone_array.length < 10 || (phone_array.length == 11 && phone_array[0] != 1) || phone_array.length > 11
    return 'Sorry, the number provided is not a valid phone number'
  elsif phone_array.length == 11
    phone_array = phone_array[1..10]
  end

  "(#{phone_array[0..2].join('')}) #{phone_array[3..5].join('')}-#{phone_array[6..9].join('')}"
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def get_peak_hours(contents)
  signup_times = []
  contents.each { |row| signup_times << row[:regdate] }
  sign_up_hours = signup_times.reduce(Hash.new(0)) do |results, date|
    hour = Time.strptime(date, "%m/%d/%y %k:%M").hour
    results[hour] += 1
    results
  end
  sign_up_hours.sort_by { |hour, signups| signups }.reverse
end

def get_peak_days(contents)
  signup_dates = []
  contents.each { |row| signup_dates << row[:regdate] }
  sign_up_days = signup_dates.reduce(Hash.new(0)) do |results, date|
    day_of_week = Time.strptime(date, "%m/%d/%y").strftime("%A")
    results[day_of_week] += 1
    results
  end
  sign_up_days.sort_by { |day, signups| signups }.reverse
end

puts 'Event manager initialized'

contents = CSV.open(
  # Choose the file you want to work with
  'event_attendees_full.csv',
  #'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def create_letters(contents)
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter

  contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = cleaned_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)
    save_thank_you_letter(id, form_letter)
  end
end

def run_assignments(contents)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = 'output/telephone_nums.csv'

  File.open(filename, 'w') do |file|
    contents.each do |row|
      name = row[:first_name]
      phone_number = cleaned_phone_number(row[:homephone])
      file.puts "#{name}\t#{phone_number}"
    end
  end
  contents.rewind
  p "The peak hours are: #{get_peak_hours(contents)}"
  contents.rewind
  p "The peak hours are: #{get_peak_days(contents)}"
end

run_assignments(contents)
