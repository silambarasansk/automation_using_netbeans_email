# HEADER FILES
require 'rest-client'
require 'rubygems'
require 'mysql2'
require 'gmail'
require 'net/http'
require 'addressable/uri'
require 'axlsx'

# CREATING XLSX INSTANCE
@p = Axlsx::Package.new
@wb = @p.workbook
@style = @wb.styles.add_style :height=>10,:alignment => {:wrap_text => true}
@sheet = @wb.add_worksheet(:name => 'Report')
@i=0
@sheet.add_row

@sheet.rows[@i].add_cell 'SCENARIO'
@sheet.rows[@i].add_cell 'RESPONSE RESULT'
@sheet.rows[@i].add_cell 'REMARKS'
@sheet.rows[@i].add_cell 'DB MID'
@sheet.rows[@i].add_cell 'JSON MID'
@sheet.rows[@i].add_cell 'DB AND JSON MID RESULT'
@sheet.rows[@i].add_cell 'DB MAIL SUBJECT'
@sheet.rows[@i].add_cell 'JSON MAIL SUBJECT'
@sheet.rows[@i].add_cell 'DB AND JSON RESULT MAIL SUBJECT'
@sheet.rows[@i].add_cell 'DB RECEPIENT'
@sheet.rows[@i].add_cell 'JSON RECEPIENT'
@sheet.rows[@i].add_cell 'DB AND JSON RESULT RECEPIENT'

# DATABASE CREDENTIALS
$db_host_address = "10.20.50.53"
$db_username     = "qa_user"
$db_password     = "qauser@123"

# GMAIL CREDENTIALS
$gmail_username = ''
$gmail_password = ''
$gmail_to_address = ""

# HTTP URL
http_scenario_1 =
        'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_2 =
        'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgHTML=<html> <body>  <p>Dear{Venkatesh},</p> Your Account {11223121} has been de-activated from {10 Apr}  to {30 Apr} Thanks {HDFC BANK} <p></p> </body> </html>'

http_scenario_3 =
          'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgHTML=&TemplateID=1&TemplateValues=fname:sriram,AccNo:12345,StartDate:10-01-2011,EndDate:10-10-2016,BANK:KOTAK'

http_scenario_5 =
           'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgHTML=Message&TemplateID=1&TemplateValues=fname:sriram,AccNo:12345,StartDate:10-01-2011,EndDate:10-10-2016,BANK:KOTAK'

http_scenario_6 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message&TemplateID=11&TemplateValues=fname:sriram,AccNo:12345,StartDate:10-01-2011,EndDate:10-10-2016,BANK:KOTAK'

http_scenario_7 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest&msgPlain=Message'

http_scenario_8 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=test&msgPlain=test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message test message'

http_scenario_10 =
             'http://10.20.50.69:18080/email?uname=venk&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_11 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_12 =
             'http://10.20.50.69:18080/email?uname=venkatadmin&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_13 =
             'http://10.20.50.69:18080/email?uname=satemail22&pass=Q3i1N@c~&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_14 =
             'http://10.20.50.69:18080/email?uname=sattest&pass=E9e)s9K$&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_15 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgHTML=test&TemplateID=00000&TemplateValues=fname:sriram,AccNo:12345,StartDate:10-01-2011,EndDate:10-10-2016,BANK:KOTAK'

http_scenario_16 =
             'http://10.20.50.69:18080/email?uname=satemail&pass=lounge&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_17 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venky.viswa@yahoo.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venkatesh.viswa@gmail.com&subject=Test&msgPlain=Message'

http_scenario_18 =
             'http://10.20.50.69:18080/email?uname=venkat&pass=venkat&fromEmail=venkatesh.viswa@gmail.com&fromName=Venkatesh&toEmail=venkatesh.viswa@rediffmail.com&replyTo=venky.viswa@yahoo.com&subject=Test&msgPlain=Message'

# CREATING OBJECT REFERENCE FOR DATABASE
@db_login = Mysql2::Client.new(:host => $db_host_address, :username => $db_username,:password=> $db_password, :database => 'email_billing')

##############################################################################
# Description:
#   Getting HTTP respose by sending request, and parsing the params in URL
#   to hash
#
# Arguments:
#   input_url:- String value of input URL
#
# Returns:
#   response:-          Response body of HTTP request in string value
#   input_param_hash:-  Parsed params value in URL in hash format
##############################################################################
def http_email(input_url)
  uri = URI input_url
  response = Net::HTTP.get(uri)
  uri1 = Addressable::URI.parse input_url
  input_param_hash = uri1.query_values
  return response, input_param_hash
end

##############################################################################
# Description:
#   Validating the Response MID and Ensuring that entry is created in DB.
#
# Arguments:
#   response:-          Contains the Response body content
#   input_param_hash:-  Contains Input params in hash format
#   expected_body:-     Contains the String expected value for Negative cases,
#                       No value passed for Positive cases, defaults to nil.
##############################################################################
def database(response, input_param_hash, expected_body=nil)
  sleep 0.7
  if expected_body.nil?
    if response.include? 'Failure'
      puts 'FAIL: Incorrect Response received, MID is not generated'
      @sheet.rows[@i].add_cell 'FAIL', :style=> @style
      @sheet.rows[@i].add_cell 'Incorrect Response received, MID is not generated', :style=> @style
    else
      db_output = @db_login.query("select * from email_billing.email_billing where MID= '#{response}'")
      @database_output = db_output.first     # CONVERTING DATABASE RESPONSE TO HASH
      unless @database_output.nil?
        puts "PASS: MID Generated: #{response}, Entry created in database"
        @sheet.rows[@i].add_cell 'PASS', :style=> @style
        @sheet.rows[@i].add_cell "MID Generated: #{response}, Entry created in database", :style=> @style
        verifications(response, input_param_hash, @database_output)
      else
        puts "FAIL: MID Generated: #{response}, Entry not created in database"
        @sheet.rows[@i].add_cell 'FAIL', :style=> @style
        @sheet.rows[@i].add_cell "MID Generated: #{response}, Entry not created in database", :style=> @style
      end
    end
  else
    if response == expected_body
      puts "PASS: Expected: #{expected_body} Actual: #{response}"
      @sheet.rows[@i].add_cell 'PASS', :style=> @style
      @sheet.rows[@i].add_cell "Expected: #{expected_body} Actual: #{response}", :style=> @style
    else
      puts "FAIL: Expected: #{expected_body} Actual: #{response}"
      @sheet.rows[@i].add_cell 'FAIL', :style=> @style
      @sheet.rows[@i].add_cell "Expected: #{expected_body} Actual: #{response}", :style=> @style
    end
  end
end

##############################################################################
# Description:
#   Verifying the Response MID and Input Params with Database Output
#
# Arguments:
#   response:-          Contains the Response body content
#   input_param_hash:-  Contains Input params in hash format
#   database_output:-   Contains the Database output in hash format
##############################################################################
def verifications(response, input_param_hash, database_output)
  # VERIFICATION OF RESPONSE MID WITH DATABASE MID
  @sheet.rows[@i].add_cell "#{database_output['mid']}", :style=> @style
  @sheet.rows[@i].add_cell "#{response}", :style=> @style
  if response = database_output['mid']
    puts "URL Response message id : #{response} matches with Database message Id: #{database_output['mid']}"
    @sheet.rows[@i].add_cell "PASS", :style=> @style
  else
    puts "URL Response message id : #{response} mismatches with Database message Id: #{database_output['mid']}"
    @sheet.rows[@i].add_cell "FAIL", :style=> @style
  end

  # VERIFICATION OF RESPONSE SUBJECT WITH DATABASE SUBJECT
  @sheet.rows[@i].add_cell "#{database_output['subject']}", :style=> @style
  @sheet.rows[@i].add_cell "#{input_param_hash['subject']}", :style=> @style
  if input_param_hash['subject'] = database_output['subject']
    puts "URL Params subject : #{input_param_hash['subject']} matches with Database Email Subject :#{database_output['subject']}"
    @sheet.rows[@i].add_cell "PASS", :style=> @style
  else
    puts "URL Params subject : #{input_param_hash['subject']} mismatches with Database Email Subject :#{database_output['subject']}"
    @sheet.rows[@i].add_cell "FAIL", :style=> @style
  end

  # VERIFICATION OF RESPONSE EMAIL ADDRESS WITH DATABASE EMAIL ADDRESS
  @sheet.rows[@i].add_cell "#{database_output['to_email']}", :style=> @style
  @sheet.rows[@i].add_cell "#{input_param_hash['toEmail']}", :style=> @style
  if input_param_hash['toEmail'] = database_output['to_email']
    puts "URL Params Recipient Email Address : #{input_param_hash['toEmail']} matches with Database Recipient Email Address : #{database_output['to_email']}"
    @sheet.rows[@i].add_cell "PASS", :style=> @style
  else
    puts "URL Params Recipient Email Address : #{input_param_hash['toEmail']} mismatches with Database Recipient Email Address : #{database_output['to_email']}"
    @sheet.rows[@i].add_cell "FAIL", :style=> @style
  end
end

##############################################################################
# Description:
#   Adding new row in the Report excel and then adding scenario description
#   in the Cell
#
# Arguments:
#   message:- Scenario description
##############################################################################
def insert_scenario(message)
  @sheet.add_row
  @i=@i+1
  @sheet.rows[@i].add_cell message, :style=> @style
end

# Verification of successful Plain email delivery without attachment
puts "### SCENARIO 1: VERIFICATION OF PLAIN EMAIL DELIVERY ###"
insert_scenario 'SCENARIO 1: VERIFICATION OF PLAIN EMAIL DELIVERY'
rest_client_output_scenario_1, input_params_hash_1 = http_email(http_scenario_1)
database(rest_client_output_scenario_1, input_params_hash_1)


# Verification of successful Plain email delivery with attachment
puts "### SCENARIO 2: VERIFICATION OF PLAIN EMAIL DELIVERY WITH ATTACHMENT ###"
insert_scenario 'SCENARIO 2: VERIFICATION OF PLAIN EMAIL DELIVERY WITH ATTACHMENT'
rest_client_output_scenario_2, input_params_hash_2 = http_email(http_scenario_2)
database(rest_client_output_scenario_2, input_params_hash_2)

# Verification of email with template configured in user template
puts "### SCENARIO 3: VERIFICATION OF EMAIL DELIVERY WITH USER CONFIGURED TEMPLATE ###"
insert_scenario 'SCENARIO 3: VERIFICATION OF EMAIL DELIVERY WITH USER CONFIGURED TEMPLATE'
rest_client_output_scenario_3, input_params_hash_3 = http_email(http_scenario_3)
database(rest_client_output_scenario_3, input_params_hash_3)

# Verification of email with template with plain body
puts "### SCENARIO 5: VERIFICATION OF EMAIL DELIVERY WITH PLAIN BODY TEMPLATE ###"
insert_scenario 'SCENARIO 5: VERIFICATION OF EMAIL DELIVERY WITH PLAIN BODY TEMPLATE'
rest_client_output_scenario_5, input_params_hash_5 = http_email(http_scenario_5)
database(rest_client_output_scenario_5, input_params_hash_5)

# Verification of email with template with HTML body
puts "### SCENARIO 6: VERIFICATION OF EMAIL DELIVERY WITH HTML BODY ###"
insert_scenario 'SCENARIO 6: VERIFICATION OF EMAIL DELIVERY WITH HTML BODY'
rest_client_output_scenario_6, input_params_hash_6 = http_email(http_scenario_6)
database(rest_client_output_scenario_6, input_params_hash_6)

# Verification of email subject Length Validation
puts "### SCENARIO 7: VERIFICATION OF EMAIL SUBJECT LENGTH VALIDATION ###"
insert_scenario 'SCENARIO 7: VERIFICATION OF EMAIL SUBJECT LENGTH VALIDATION'
rest_client_output_scenario_7, input_params_hash_7 = http_email(http_scenario_7)
database(rest_client_output_scenario_7, input_params_hash_7)

# Verification of email body length Validation
puts "### SCENARIO 8: VERIFICATION OF EMAIL BODY LENGTH VALIDATION ###"
insert_scenario 'SCENARIO 8: VERIFICATION OF EMAIL BODY LENGTH VALIDATION'
rest_client_output_scenario_8, input_params_hash_8 = http_email(http_scenario_8)
database(rest_client_output_scenario_8, input_params_hash_8)

# Verification of Invalid source address / reply to / recipient
puts "### SCENARIO 10: VERIFICATION OF INVALID SOURCE ADDRESS/ REPLY TO/ RECIPIENT ###"
insert_scenario 'SCENARIO 10: VERIFICATION OF INVALID SOURCE ADDRESS/ REPLY TO/ RECIPIENT'
rest_client_output_scenario_10, input_params_hash_10 = http_email(http_scenario_10)
database(rest_client_output_scenario_10, input_params_hash_10, expected_body = 'Failure:Access Denied due to unauthorized Username / Password / IP / Media / Service')

# Verification of Account Deactivation
puts "### SCENARIO 11: VERIFICATION OF ACCOUNT DEACTIVATION ###"
insert_scenario 'SCENARIO 11: VERIFICATION OF ACCOUNT DEACTIVATION'
rest_client_output_scenario_11, input_params_hash_11 = http_email(http_scenario_11)
database(rest_client_output_scenario_11, input_params_hash_11, expected_body = 'Failure:Invalid Source/ReplyTo/Reciepient  E-mail ID/Field . As per Email standard, the Email ID should not have invalid characters.')

# Verification of Credit Expired
puts "### SCENARIO 12: VERIFICATION OF EXPIRED CREDITS ###"
insert_scenario 'SCENARIO 12: VERIFICATION OF EXPIRED CREDITS'
rest_client_output_scenario_12, input_params_hash_12 = http_email(http_scenario_12)
database(rest_client_output_scenario_12, input_params_hash_12, expected_body = 'Failure:Account deactivated/expired')

# Verification of Email media not assigned
puts "### SCENARIO 13: VERIFICATION OF EMAIL MEDIA NOT ASSIGNED ###"
insert_scenario 'SCENARIO 13: VERIFICATION OF EMAIL MEDIA NOT ASSIGNED'
rest_client_output_scenario_13, input_params_hash_13 = http_email(http_scenario_13)
database(rest_client_output_scenario_13, input_params_hash_13, expected_body = 'Failure:Email Credits Expired')

# Verification of Invalid template id
puts "### SCENARIO 14: VERIFICATION OF INVALID TEMPLATE ID ###"
insert_scenario 'SCENARIO 14: VERIFICATION OF INVALID TEMPLATE ID'
rest_client_output_scenario_14, input_params_hash_14 = http_email(http_scenario_14)
database(rest_client_output_scenario_14, input_params_hash_14, expected_body = 'Failure:Email Media not Assigned')

# Verification of No Credit available
puts "### SCENARIO 15: VERIFICATION OF NO AVAILABLE CREDITS ###"
insert_scenario 'SCENARIO 15: VERIFICATION OF NO AVAILABLE CREDITS'
rest_client_output_scenario_15, input_params_hash_15 = http_email(http_scenario_15)
database(rest_client_output_scenario_15, input_params_hash_15, expected_body = 'Failure:Invalid Template ID')

# Verification of  from email id  configuration
puts "### SCENARIO 16: VERIFICATION OF FROM EMAIL ID ###"
insert_scenario 'SCENARIO 16: VERIFICATION OF FROM EMAIL ID'
rest_client_output_scenario_16, input_params_hash_16 = http_email(http_scenario_16)
database(rest_client_output_scenario_16, input_params_hash_16, expected_body = 'Failure:No credits available in the account')

# Verification of  reply to email id  configuration
puts "### SCENARIO 17: VERIFICATION OF REPLY TO EMAIL ID ###"
insert_scenario 'SCENARIO 17: VERIFICATION OF REPLY TO EMAIL ID'
rest_client_output_scenario_17, input_params_hash_17 = http_email(http_scenario_17)
database(rest_client_output_scenario_17, input_params_hash_17, expected_body = 'Failure:From email id not configured')

# Verification of successful  email delivery with multiple attachment
puts "### SCENARIO 18: VERIFICATION OF EMAIL DELIVERY WITH MULTIPLE ATTACHMENTS ###"
insert_scenario 'SCENARIO 18: VERIFICATION OF EMAIL DELIVERY WITH MULTIPLE ATTACHMENTS'
rest_client_output_scenario_18, input_params_hash_18 = http_email(http_scenario_18)
database(rest_client_output_scenario_18, input_params_hash_18, expected_body = 'Failure:Reply-To email id not configured')

# CREATING EXCEL REPORT FILE
@sheet.column_widths 80
@p.serialize "D:/Result#{Time.now.strftime('%m%d%y%H%M%S')}.xlsx"