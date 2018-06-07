### TESTCASES ###
#1. Open Rest client -> Set Request headers <Name = Content-Type, Value = application/json>
#2. Set method as Post -> load url: http://10.20.50.69:18080/sendEmail
#3. Enter Request Body content -> Click send
#4. Validate the body response with the database table using message ID
#5. Check Gmail content for the API response

# HEADER FILES
require 'rubygems'
require 'mysql2'
require 'gmail'
require 'net/ftp'
require 'uri'
require 'net/ssh'
require 'net/ftp'

# DATABASE CREDENTIALS
db_host_address = "10.20.50.53"
db_username     = "qa_user"
db_password     = "qauser@123"
db_esme_address = "79805800000000"

# FTP CREDENTIALS
ftp_file_location  = "C:/Users/dbthangarasu/Desktop/Mgage India/abc.txt"
ftp_file_location1 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc1.txt"
ftp_file_location2 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc2.txt"
ftp_file_location3 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc5.txt"
ftp_file_location4 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc3.txt"
ftp_file_location5 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc4.txt"
ftp_file_location6 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc6.txt"
ftp_file_location7 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc7.txt"
ftp_file_location8 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc8.txt"
ftp_file_location9 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc9.zip"
template_location  = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/template1.html"
template_location1 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/template.txt"
template_location2 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc8.txt.done"
template_location3 = "C:/Users/dbthangarasu/Desktop/Mgage India/Email FTP/Input and Email Body content files/abc9.zip.done"

# SSH CREDENTIALS
ssh_hostname = "10.20.50.69"
ssh_username = "sksubrahmanyam"
ssh_password = "Santh456Santh@"
ssh_tail_command = "/home/apps/EMAIL_FILE_PROCESSOR/log/email_file_processor.log"

# CONNECTING BILLING DATABASE TO FETCH FTP CREDENTIALS
def fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
  unless db_esme_address.nil? || db_esme_address == ''
    sleep 5
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'billing')
    update_query = db_login.query("UPDATE email.inboxed_ftp_rule SET templateFile=NULL, FILE=NULL, text='Test Sample', template_id=NULL WHERE Esmeaddr ='#{db_esme_address}'")
    db_output = db_login.query("SELECT * FROM proftpd.`ftp_email_users` WHERE esmeaddr ='#{db_esme_address}'")
    database_output = db_output.first     # CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == 0
      database_ftp_file_pattern       = database_output['input_file_pattern']
      database_ftp_esme_address       = database_output['esmeaddr']
      database_ftp_host               = database_output['ftp_host']
      database_ftp_destination_dir    = database_output['destinationdir']
      database_ftp_home_dir           = database_output['homedir']
      database_ftp_username           = database_output['remote_user']
      database_ftp_password           = database_output['remote_passwd']
      database_ftp_attachment_pattern = database_output['attachment_file_pattern']
      database_ftp_port               = database_output['ftp_port']
      puts "#DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON ESME ADDRESS:\n #{database_output}"
      db_login.close
    else
      puts 'Database Query is Invalid or Data is not Inserted in Billing Table'
    end
  else
    puts 'Invalid ESME Address or Unable to fetch database response'
  end
  return database_output
end

# FTP FILE UPLOAD VALIDATION
def ftp_file_upload(database_output, ftp_file_location)
  if database_output['ftp_host'] == '' or database_output['remote_user'] == '' or database_output['remote_passwd'] == ''
    puts 'Invalid FTP credentials fetched from Database'
  else
    # UPLOADING FILES THROUGH FTP
    file_path = File.new(ftp_file_location)
    Net::FTP.open(database_output['ftp_host'], database_output['remote_user'], database_output['remote_passwd']) do |ftp|
      puts "\n#FTP RESPONSE SHOWN ON LOGGED VIA DATABASE CREDENTIALS"
      if ftp.closed?
        puts "Invalid FTP Credentials or Try with different FTP credentials"
      else
        puts "FTP Login is successfull : #{database_output['remote_user']}"
        ftp.putbinaryfile(file_path)
        @log_time_stamp = Time.now
        puts "File upload is successfull in FTP"
      end
    end
  end
end

# FTP FILE UPLOAD VALIDATION
def ftp_multiple_files_upload(database_output, ftp_file_location, ftp_template_location)
  if database_output['ftp_host'] == '' or database_output['remote_user'] == '' or database_output['remote_passwd'] == ''
    puts 'Invalid FTP credentials fetched from Database'
  else
    # UPLOADING FILES THROUGH FTP
    file_path     = File.new(ftp_file_location)
    template_path = File.new(ftp_template_location)
    Net::FTP.open(database_output['ftp_host'], database_output['remote_user'], database_output['remote_passwd']) do |ftp|
      puts "\n#FTP RESPONSE SHOWN ON LOGGED VIA DATABASE CREDENTIALS"
      if ftp.closed?
        puts "Invalid FTP Credentials or Try with different FTP credentials"
      else
        puts "FTP Login is successfull : #{database_output['remote_user']}"
        ftp.putbinaryfile(template_path)
        puts "Uploaded Additional Body content file successfully "
        ftp.putbinaryfile(file_path)
        puts "Uploaded Input file successfully "
        @log_time_stamp = Time.now
        puts "File upload is successfull in FTP"
      end
    end
  end
end

# VAILDATING LOG FILES USING SSH
def do_tail( session, ssh_tail_command )
  session.open_channel do |channel|
    channel.on_data do |ch, data|
      puts "Fetched SSH Log using Tail Command :"
      puts "[#{ssh_tail_command}] -> #{data}"
      if "[#{ssh_tail_command}] -> #{data}".include? 'Completedtrue' or "[#{ssh_tail_command}] -> #{data}".include? @log_time_stamp.strftime('%Y-%m-%d %H:%M:%S')
        tail_log = data.scan(/.*/)
        tail_log.rindex('Completedtrue')
        completed_tail_log = tail_log[tail_log.rindex('Completedtrue') - 2]
        puts "\nFetched Completed Tail Log :\nCompleted Log: #{completed_tail_log}"
        $ssh_fetched_success_log = tail_log[tail_log.rindex('Completedtrue') - 2].scan(/Distribute.*/)[0].delete('Distribute').split(':')
        puts "Fetched SSH ESME Address from tail log :#{$ssh_fetched_success_log[0]}"
        puts "Fetched SSH MID from tail log :#{$ssh_fetched_success_log[1]}"
      else
        puts "SSH Email File Processor is not working or FTP files are not uploaded"
      end
    end
    sleep 5
    puts channel.exec "tail #{ssh_tail_command}"
  end
end

# SSH LOGIN AND FETCHING DATAS
def ssh_login(do_tail, ssh_hostname, ssh_username, ssh_password)
  if ssh_hostname == '' or ssh_username == '' or ssh_password == ''
    puts "Invalid SSH credentials is given"
  else
    Net::SSH.start(ssh_hostname, ssh_username, :password => ssh_password) do |session|
      puts "\n### OVERALL FETCHED TAIL LOG IN SSH CLIENT ###"
      if session.closed?
        puts 'SSH Email File Processor is not working or FTP files are not uploaded'
      else
        puts "SSH Login is successfull : #{ssh_username}"
        do_tail session, "/home/apps/EMAIL_FILE_PROCESSOR/log/email_file_processor.log"
        session.loop
      end
    end
  end
end

def verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
  # CONNECTING BILLING DATABASE AND VERIFYING SSH RESPONSE
  if $ssh_fetched_success_log[1] == '' or $ssh_fetched_success_log[1].nil?
    puts "Unable to fetch MID and ESME Address from SSH Secure CLient"
  else
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'email_billing')
    db_output = db_login.query("SELECT * FROM email_billing.email_billing WHERE MID='#{$ssh_fetched_success_log[1]}'")
    database_output = db_output.first
    puts "\n#EMAIL BILLING DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON SSH MESSAGE ID:\n"
    unless database_output.nil? || database_output == ''
      database_message_id              = database_output['mid']
      database_esme_address            = database_output['esmeaddr']
      database_to_recipient_address    = database_output['to_email']
      database_from_email_adddress     = database_output['from_email']
      database_reply_to_email_address  = database_output['reply_to']
      database_message_subject         = database_output['subject']
      database_message_status          = database_output['status']
      database_cust_mid                = database_output['cust_mid']
      database_credits                 = database_output['credits']
      database_mail_size               = database_output['mail_size']
      database_mtag                    = database_output['mtag']
      database_aid                     = database_output['aid']
      database_pid                     = database_output['pid']
      puts database_output
      puts "Database Message Id : #{database_message_id}"
      db_login.close
    else
       puts 'Database Query is Invalid or Data is not Inserted in Email Billing Table due to time delay'
    end
  end
end

# VERIFY SSH RESPONSE IN EMAIL DELIVERY DATABASE
def verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)
  if db_host_address == '' or db_username == '' or db_password == ''
    puts "Inavalid Database Login credentials is given"
  else
    sleep 10
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'email_billing')
    db_output = db_login.query("SELECT * FROM email_billing.email_delivery WHERE MID='#{$ssh_fetched_success_log[1]}'")
    database_output = db_output.first
    puts "\n#EMAIL DELIVERY DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON SSH MESSAGE ID:\n"
    #CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == ''
      database_ssh_to_email_address   = database_output['to_email']
      database_ssh_mid                = database_output['mid']
      database_ssh_mail_status        = database_output['status']
      database_ssh_stime              = database_output['stime']
      database_ssh_esme_address       = database_output['esmeaddr']
      puts database_output
      db_login.close
    else
      puts 'Database Query is Invalid or Data is not Inserted in Email Delivery Table due to time delay'
    end
  end
end

# UPDATING INBOX STATIC BODY IN DATABASE
def update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
  if db_host_address == '' or db_username == '' or db_password == '' or db_esme_address == ''
    puts "Invalid Database Login credentials is given"
  else
    sleep 5
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'email')
    update_body_text = db_login.query("UPDATE email.inboxed_ftp_rule SET TEXT='Default sample body text' WHERE Esmeaddr =#{db_esme_address}")
    db_output        = db_login.query("SELECT * FROM email.inboxed_ftp_rule WHERE Esmeaddr ='#{db_esme_address}'")
    database_output  = db_output.first
    puts "\n#EMAIL INBOX FTP RULE DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON ESME ADDRESS:\n"
    #CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == 0
      database_mail_headers        = database_output['headerincluded']
      database_mail_body_text      = database_output['text']
      database_mail_esme_address   = database_output['esmeaddr']
      puts "Email Static body is set as per inboxed ftp rule as : #{database_mail_body_text}"
      puts database_output
      db_login.close
    else
      puts 'Database Query is Invalid or Database Record is not available for the given ESME Address'
    end
  end
end

# UPDATING INBOX STATIC BODY MTAGS IN DATABASE
def update_email_mtags_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
  if db_host_address == '' or db_username == '' or db_password == '' or db_esme_address == ''
    puts "Invalid Database Login credentials is given"
  else
    sleep 5
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'email')
    update_body_text = db_login.query("
                                       UPDATE email.inboxed_ftp_rule SET msg_tag='msg1',
                                       mtag2='msg2', mtag3='msg3', mtag4='msg4', mtag5='msg5',
                                       mtag6='msg6', mtag7='msg7', mtag8='msg8', mtag9='msg9',
                                       mtag10='msg10' WHERE esmeaddr ='#{db_esme_address}'
                                     ")
    db_output        = db_login.query("SELECT * FROM email.inboxed_ftp_rule WHERE Esmeaddr ='#{db_esme_address}'")
    database_output  = db_output.first
    puts "\n#EMAIL INBOX FTP RULE DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON ESME ADDRESS:\n"
    #CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == 0
      database_mail_headers        = database_output['headerincluded']
      database_mail_body_text      = database_output['text']
      database_mail_esme_address   = database_output['esmeaddr']
      database_message_tag         = database_output['msg_tag']
      database_mtag_2              = database_output['mtag2']
      database_mtag_3              = database_output['mtag3']
      database_mtag_4              = database_output['mtag4']
      database_mtag_5              = database_output['mtag5']
      database_mtag_6              = database_output['mtag6']
      database_mtag_7              = database_output['mtag7']
      database_mtag_8              = database_output['mtag8']
      database_mtag_9              = database_output['mtag9']
      database_mtag_10             = database_output['mtag10']
      puts database_output
      puts "\nEmail Static message tag is set as per inboxed ftp rule as : #{database_message_tag}"
      puts "Email M-tag2 is set as per inboxed ftp rule as : #{database_mtag_2}"
      puts "Email M-tag3 is set as per inboxed ftp rule as : #{database_mtag_3}"
      puts "Email M-tag4 is set as per inboxed ftp rule as : #{database_mtag_4}"
      puts "Email M-tag5 is set as per inboxed ftp rule as : #{database_mtag_5}"
      puts "Email M-tag6 is set as per inboxed ftp rule as : #{database_mtag_6}"
      puts "Email M-tag7 is set as per inboxed ftp rule as : #{database_mtag_7}"
      puts "Email M-tag8 is set as per inboxed ftp rule as : #{database_mtag_8}"
      puts "Email M-tag9 is set as per inboxed ftp rule as : #{database_mtag_9}"
      puts "Email M-tag10 is set as per inboxed ftp rule as : #{database_mtag_10}"
      db_login.close
    else
      puts 'Database Query is Invalid or Database Record is not available for the given ESME Address'
    end
  end
end

# UPDATING INBOX STATIC BODY IN DATABASE
def update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
  if db_host_address == '' or db_username == '' or db_password == '' or db_esme_address == ''
    puts "Invalid Database Login credentials is given"
  else
    sleep 5
    db_login = Mysql2::Client.new(:host => db_host_address, :username => db_username,:password=> db_password, :database => 'email')
    update_template_file = db_login.query("UPDATE email.inboxed_ftp_rule SET templateFile='temp', TEXT='NULL' WHERE Esmeaddr ='#{db_esme_address}'")
    db_output            = db_login.query("SELECT * FROM email.inboxed_ftp_rule WHERE Esmeaddr ='#{db_esme_address}'")
    database_output      = db_output.first
    puts "\n#EMAIL INBOX FTP RULE DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON ESME ADDRESS:\n"
    #CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == 0
      database_mail_template_file  = database_output['templateFile']
      database_mail_body_text      = database_output['text']
      puts "Email Template File is set as per inboxed ftp rule as : #{database_mail_template_file}"
      puts "Email Body Text is set as per inboxed ftp rule as : #{database_mail_body_text}"
      puts database_output
      db_login.close
    else
      puts 'Database Query is Invalid or Database Record is not available for the given ESME Address'
    end
  end
end

puts "### SCENARIO 1 - EMAIL FTP SMOKE TESTING ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 2 - EMAIL INBOX FTP RULE STATIC BODY UPDATE ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 3 - EMAIL INBOX MTAGS UPDATE ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_mtags_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location1)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 4 - EMAIL INBOX HTML TEMPLATE FILE UPDATE ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location2, template_location)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 5 - EMAIL INBOX HTML TEMPLATE FILE UPDATE BY PASSING CUSTOM PARAMATERS AS HEADER VALUES ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location3, template_location)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 6 - EMAIL INBOX TEXT TEMPLATE FILE UPDATE AS EMAIL BODY CONTENT ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location4, template_location1)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 7 - EMAIL WITH TEXT AS EMAIL BODY CONTENT ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location5, template_location1)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 8 - EMAIL WITH TEMPLATE ID AS EMAIL BODY CONTENT ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location6)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 9 - EMAIL WITH TEMPLATE ID AS BODY CONTENT AND PASSING PARAMETERS TO CONFIGURED TEMPLATE ID ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location7)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 10 - EMAIL WITH TEMPLATE ID AS BODY CONTENT FROM INBOXED FTP RULE AND PASSING PARAMETERS TO CONFIGURED TEMPLATE ID ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_file_upload(ftp_database_output, ftp_file_location8)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 11 - EMAIL WITH TEMPLATE ID AS BODY CONTENT FROM INBOXED FTP RULE AND PASSING PARAMETERS TO CONFIGURED TEMPLATE ID WITH MARKER VALUE###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location8, template_location2)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 12 - ZIP FILE PROCCESSING WITH MARKER VALUE ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location9, template_location3)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)

puts "\n### SCENARIO 13 - EMAIL BODY CONTENT STORING IN EMAIL BILLING TABLE ###"
ftp_database_output = fetch_ftp_users_info_from_database(db_host_address, db_username, db_password, db_esme_address)
update_email_template_file_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
update_email_static_body_in_email_inboxed_ftp_database(db_host_address, db_username, db_password, db_esme_address)
ftp_multiple_files_upload(ftp_database_output, ftp_file_location9, template_location3)
ssh_login(method(:do_tail), ssh_hostname, ssh_username, ssh_password)
verify_ssh_response_in_email_billing_database(db_host_address, db_username, db_password)
verify_ssh_response_in_email_delivery_database(db_host_address, db_username, db_password)