require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
    phone_number = phone_number.delete "-" " " "(" ")" "."
    if phone_number.length == 11 && phone_number.start_with?("1")
        phone_number[1..10]
    elsif phone_number.length == 10
        phone_number
    else
        "Invalid phone number."
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def find_reg_hour(reg_info)
    DateTime.strptime(reg_info, '%m/%d/%y %H:%M').hour
end

def find_reg_day(reg_info)
    case DateTime.strptime(reg_info, '%m/%d/%y %H:%M').wday
    when 0
        "Sunday"
    when 1
        "Monday"
    when 2
        "Tuesday"
    when 3
        "Wednesday"
    when 4
        "Thursday"
    when 5 
        "Friday"
    when 6 
        "Saturday"
    end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  hour = find_reg_hour(row[:regdate])
  day = find_reg_day(row[:regdate])
  phone_number = clean_phone_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

    puts " #{name} #{hour} #{day}"
#   form_letter = erb_template.result(binding)
#   save_thank_you_letter(id,form_letter)
end