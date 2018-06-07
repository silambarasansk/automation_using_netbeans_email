### TESTCASES ###
#1. Open Rest client -> Set Request headers <Name = Content-Type, Value = application/json>
#2. Set method as Post -> load url: http://10.20.50.69:18080/sendEmail
#3. Enter Request Body content -> Click send
#4. Validate the body response with the database table using message ID
#5. Check Gmail content for the API response

# HEADER FILES
require 'rest-client'
require 'rubygems'
require 'json'
require 'rubygems'
require 'mysql2'
require 'gmail'
require 'axlsx'

# VARIABLE DECLARATION
value = Time.now.strftime("%m%d%y%H%M%S")

# CREATING XLSX INSTANCE
@p = Axlsx::Package.new
@wb = @p.workbook
@style = @wb.styles.add_style :height=>50,:alignment => {:wrap_text => true}
@sheet = @wb.add_worksheet(:name => "Table")
@i=0
@sheet.add_row

@sheet.rows[@i].add_cell 'JSON INPUT'
@sheet.rows[@i].add_cell 'STATUS CODE'
@sheet.rows[@i].add_cell 'STATUS DESCRIPTION'
@sheet.rows[@i].add_cell 'DB RESULT'
@sheet.rows[@i].add_cell 'DB MID'
@sheet.rows[@i].add_cell 'JSON MID'
@sheet.rows[@i].add_cell 'DB AND JSON MID COMPARSION RESULT'
@sheet.rows[@i].add_cell 'DB MAIL SUBJECT'
@sheet.rows[@i].add_cell 'JSON MAIL SUBJECT'
@sheet.rows[@i].add_cell 'DB AND JSON RESULT MAIL SUBJECT'
@sheet.rows[@i].add_cell 'DB RECEPIENT'
@sheet.rows[@i].add_cell 'JSON RECEPIENT'
@sheet.rows[@i].add_cell 'DB AND JSON RESULT RECEPIENT'
@sheet.rows[@i].add_cell 'DB MTAG'
@sheet.rows[@i].add_cell 'JSON MTAG'
@sheet.rows[@i].add_cell 'DB AND JSON RESULT MTAG'



# DATABASE CREDENTIALS
$db_host_address = "10.20.50.53"
$db_username     = "qa_user"
$db_password     = "qauser@123"

# GMAIL CREDENTIALS
$gmail_username = ''
$gmail_password = ''
$gmail_to_address = ""

# JSON BODY CONTENTS
json_scenario_1 =
        '{
          "version": "1.0",
          "userName": "venkat",
          "password": "venkat",
          "includeFooter": "yes",
          "message": {
          "custRef": "testrefid",
          "html": "<p>Example HTML content<\/p>",
          "text": "Example text content",
          "subject": "Hello test message",
          "fromEmail": "venkatesh.viswa@gmail.com",
          "fromName": "Hello test message",
          "replyTo": "venkatesh.viswa@gmail.com",
          "recipient": "vvenkatesh@mgageindia.com",
          "mtag":
          { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
          }
         }'

json_scenario_2 =
        '{
          "version": "1.0",
          "userName": "venkat",
          "password": "venkat",
          "includeFooter": "yes",
          "message": {
          "custRef": "testrefid",
          "html": "<p>Example HTML content<\/p>",
          "text": "Example text content",
          "subject": "Hello test message",
          "fromEmail": "venkatesh.viswa@gmail.com",
          "fromName": "Hello test message",
          "replyTo": "venkatesh.viswa@gmail.com",
          "recipient": "testtesttestmgage@gmail.com",
          "mtag":
          { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
          "attachments": [
          { "name": "test.txt", "attachmentData": "QWN0aW9uIFR5cGUgDQpDbGljay9PcGVuDQpBY3Rpb24gdGltZSBpcyB0aW1lIG9mIE9wZW4gDQpEZXZpY2UgVHlwZSANCkNhcHR1cmVkIGZyb20gdXNlciBhZ2VudCANCi4uDQouLg0KLi4NCm1lc3NhZ2UgVGFnIA0KDQpjdXN0b21lciByZWZyZW5jZSBpZCANCg0KZmlsZV9pZCA9IGlkIHByb3ZpZGVkIHRvIGJhdGNoIGlkIGdlbmVyYXRlZCBieSB1cyANCg0KbWVzc2FnZSB0YWcgYWRpb25hbCBnaXZlbiBieSBjdXN0b21lciB1cCB0byA1IG1lc3NzYWdlIHRhZ3MgdXNlZCB0byBzdG9yZSBpbnRvIHRoZSBzdGF0cyANCg0KZHVyYXRpb24gLSBob3cgbG9uZyBoZSBzcGVudCB1cG9uIHRoZSBlbWFpbCA/DQoJPCAyIA0KCQl0byBiZSBvbiBuZXh0IHBoYXNlIA0KYWdlIG9mIG9wZW4gDQoNCg0KdmVyc2lvbiBvbiBocmVmIGNsaWNrIGEgbnVtYmVyIHNvcnQgb2YgdG8gYmUgc2VudCANCg==" }
          ]
          }
          }'

json_scenario_3 =
          '{
            "version": "1.0",
            "userName": "venkat",
            "password": "venkat",
            "includeFooter": "yes",
            "message": {
            "custRef": "testrefid",
            "html": "<p>Example HTML content<\/p>",
            "text": "Example text content",
            "subject": "Hello test message",
            "fromEmail": "venkatesh.viswa@gmail.com",
            "fromName": "Hello test message",
            "replyTo": "venkatesh.viswa@gmail.com",
            "recipient": "vvenkatesh@mgageindia.com",
            "mtag":
            { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
            ,
            "template": {
            "templateId": "1",
            "templateValues":
            { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
            }
            }
           }'

json_scenario_4 =
           '{
            "version": "1.0",
            "userName": "venkat",
            "password": "venkat",
            "includeFooter": "yes",
            "message": {
            "custRef": "testrefid",
            "html": "<p>Example HTML content<\/p>",
            "text": "Example text content",
            "subject": "Hello test message",
            "fromEmail": "venkatesh.viswa@gmail.com",
            "fromName": "Hello test message",
            "replyTo": "venkatesh.viswa@gmail.com",
            "recipient": "vvenkatesh@mgageindia.com",
            "mtag":
            { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
            }
           }'

json_scenario_5 =
           '{
            "version": "1.0",
            "userName": "venkat",
            "password": "venkat",
            "includeFooter": "yes",
            "message": {
            "custRef": "testrefid",
            "html": "",
            "text": "Example text content",
            "subject": "Hello test message",
            "fromEmail": "venkatesh.viswa@gmail.com",
            "fromName": "Hello test message",
            "replyTo": "venkatesh.viswa@gmail.com",
            "recipient": "vvenkatesh@mgageindia.com",
            "mtag":
            { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
            "template": {
            "templateId": "1",
            "templateValues":
            { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
            }
            }
           }'

json_scenario_6 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "vvenkatesh@mgageindia.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "1",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_7 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message Hello test message Hello test message Hello test message Hello test message Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "vvenkatesh@mgageindia.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "1",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_8 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message Test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "vvenkatesh@mgageindia.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "1",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_9 =
             '{
              "version": "1.0",
              "userName": "venk",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "vvenkatesh@mgageindia.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "1",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_10 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "1",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_11 =
             '{
              "version": "1.0",
              "userName": "venkatadmin",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "venkatesh.viswa@gmail.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
              }
             }'

json_scenario_12 =
             '{
              "version": "1.0",
              "userName": "satemail22",
              "password": "Q3i1N@c~",
              "includeFooter": "yes",
              "message":
              { "custRef": "testrefid", "html": "", "text": "test message", "subject": "Hello test message", "fromEmail": "sasubramani@mgageindia.com", "fromName": "Venkatesh", "replyTo": "sasubramani@mgageindia.com", "recipient": "venkatesh.viswa@rediffmail.com", "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd" }
              }
             }'

json_scenario_13 =
             '{
              "version": "1.0",
              "userName": "sattest",
              "password": "E9e)s9K$",
              "includeFooter": "yes",
              "message":
              { "custRef": "testrefid", "html": "", "text": "test message", "subject": "Hello test message", "fromEmail": "venkatesh.viswa@gmail.com", "fromName": "Venkatesh", "replyTo": "venkatesh.viswa@gmail.com", "recipient": "venkatesh.viswa@rediffmail.com", "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd" }
              }
             }'

json_scenario_14 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "100",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_15 =
             '{
              "version": "1.0",
              "userName": "satemail",
              "password": "lounge",
              "includeFooter": "yes",
              "message":
              { "custRef": "testrefid", "html": "", "text": "test message", "subject": "Hello test message", "fromEmail": "dg@mgageindia.com", "fromName": "Venkatesh", "replyTo": "dg@mgageindia.com", "recipient": "venkatesh.viswa@rediffmail.com", "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd" }
              }
             }'

json_scenario_16 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "test@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "100",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_17 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "Test message",
              "text": "",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "test@gmail.com",
              "recipient": "",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  },
              "template": {
              "templateId": "100",
              "templateValues":
              { "Name": "Ratan Pandey", "AccNo": "10220001", "StartDate": "01/02/2016", "EndDate": "01/03/2018", "BANK": "HDFC Bank Ltd." }
              }
              }
             }'

json_scenario_18 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "<p>Example HTML content<\/p>",
              "text": "Example text content",
              "subject": "Hello test message",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "testtesttestmgage@gmail.com",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
              ,
              "attachments": [
              { "name": "test.txt", "attachmentData": "QWN0aW9uIFR5cGUgDQpDbGljay9PcGVuDQpBY3Rpb24gdGltZSBpcyB0aW1lIG9mIE9wZW4gDQpEZXZpY2UgVHlwZSANCkNhcHR1cmVkIGZyb20gdXNlciBhZ2VudCANCi4uDQouLg0KLi4NCm1lc3NhZ2UgVGFnIA0KDQpjdXN0b21lciByZWZyZW5jZSBpZCANCg0KZmlsZV9pZCA9IGlkIHByb3ZpZGVkIHRvIGJhdGNoIGlkIGdlbmVyYXRlZCBieSB1cyANCg0KbWVzc2FnZSB0YWcgYWRpb25hbCBnaXZlbiBieSBjdXN0b21lciB1cCB0byA1IG1lc3NzYWdlIHRhZ3MgdXNlZCB0byBzdG9yZSBpbnRvIHRoZSBzdGF0cyANCg0KZHVyYXRpb24gLSBob3cgbG9uZyBoZSBzcGVudCB1cG9uIHRoZSBlbWFpbCA/DQoJPCAyIA0KCQl0byBiZSBvbiBuZXh0IHBoYXNlIA0KYWdlIG9mIG9wZW4gDQoNCg0KdmVyc2lvbiBvbiBocmVmIGNsaWNrIGEgbnVtYmVyIHNvcnQgb2YgdG8gYmUgc2VudCANCg==" },{ "name": "test.txt", "attachmentData": "QWN0aW9uIFR5cGUgDQpDbGljay9PcGVuDQpBY3Rpb24gdGltZSBpcyB0aW1lIG9mIE9wZW4gDQpEZXZpY2UgVHlwZSANCkNhcHR1cmVkIGZyb20gdXNlciBhZ2VudCANCi4uDQouLg0KLi4NCm1lc3NhZ2UgVGFnIA0KDQpjdXN0b21lciByZWZyZW5jZSBpZCANCg0KZmlsZV9pZCA9IGlkIHByb3ZpZGVkIHRvIGJhdGNoIGlkIGdlbmVyYXRlZCBieSB1cyANCg0KbWVzc2FnZSB0YWcgYWRpb25hbCBnaXZlbiBieSBjdXN0b21lciB1cCB0byA1IG1lc3NzYWdlIHRhZ3MgdXNlZCB0byBzdG9yZSBpbnRvIHRoZSBzdGF0cyANCg0KZHVyYXRpb24gLSBob3cgbG9uZyBoZSBzcGVudCB1cG9uIHRoZSBlbWFpbCA/DQoJPCAyIA0KCQl0byBiZSBvbiBuZXh0IHBoYXNlIA0KYWdlIG9mIG9wZW4gDQoNCg0KdmVyc2lvbiBvbiBocmVmIGNsaWNrIGEgbnVtYmVyIHNvcnQgb2YgdG8gYmUgc2VudCANCg==" }

              ]
              }
             }'

json_scenario_19 =
             '{
              "version": "1.0",
              "userName": "venkat",
              "password": "venkat",
              "includeFooter": "yes",
              "message": {
              "custRef": "testrefid",
              "html": "<p>Example HTML content<\/p>",
              "text": "Example text content",
              "subject": "Hello test message '+value+'",
              "fromEmail": "venkatesh.viswa@gmail.com",
              "fromName": "Hello test message",
              "replyTo": "venkatesh.viswa@gmail.com",
              "recipient": "'+$gmail_to_address+'",
              "mtag":
              { "mtag1": "bankvvv", "mtag2": "crcard", "mtag3": "entertainment", "mtag4": "travel", "mtag5": "movie","mtag6": "movie1","mtag7": "moviexd"  }
              ,
              "attachments": [
              { "name": "test.txt", "attachmentData": "QWN0aW9uIFR5cGUgDQpDbGljay9PcGVuDQpBY3Rpb24gdGltZSBpcyB0aW1lIG9mIE9wZW4gDQpEZXZpY2UgVHlwZSANCkNhcHR1cmVkIGZyb20gdXNlciBhZ2VudCANCi4uDQouLg0KLi4NCm1lc3NhZ2UgVGFnIA0KDQpjdXN0b21lciByZWZyZW5jZSBpZCANCg0KZmlsZV9pZCA9IGlkIHByb3ZpZGVkIHRvIGJhdGNoIGlkIGdlbmVyYXRlZCBieSB1cyANCg0KbWVzc2FnZSB0YWcgYWRpb25hbCBnaXZlbiBieSBjdXN0b21lciB1cCB0byA1IG1lc3NzYWdlIHRhZ3MgdXNlZCB0byBzdG9yZSBpbnRvIHRoZSBzdGF0cyANCg0KZHVyYXRpb24gLSBob3cgbG9uZyBoZSBzcGVudCB1cG9uIHRoZSBlbWFpbCA/DQoJPCAyIA0KCQl0byBiZSBvbiBuZXh0IHBoYXNlIA0KYWdlIG9mIG9wZW4gDQoNCg0KdmVyc2lvbiBvbiBocmVmIGNsaWNrIGEgbnVtYmVyIHNvcnQgb2YgdG8gYmUgc2VudCANCg==" },{ "name": "test.txt", "attachmentData": "QWN0aW9uIFR5cGUgDQpDbGljay9PcGVuDQpBY3Rpb24gdGltZSBpcyB0aW1lIG9mIE9wZW4gDQpEZXZpY2UgVHlwZSANCkNhcHR1cmVkIGZyb20gdXNlciBhZ2VudCANCi4uDQouLg0KLi4NCm1lc3NhZ2UgVGFnIA0KDQpjdXN0b21lciByZWZyZW5jZSBpZCANCg0KZmlsZV9pZCA9IGlkIHByb3ZpZGVkIHRvIGJhdGNoIGlkIGdlbmVyYXRlZCBieSB1cyANCg0KbWVzc2FnZSB0YWcgYWRpb25hbCBnaXZlbiBieSBjdXN0b21lciB1cCB0byA1IG1lc3NzYWdlIHRhZ3MgdXNlZCB0byBzdG9yZSBpbnRvIHRoZSBzdGF0cyANCg0KZHVyYXRpb24gLSBob3cgbG9uZyBoZSBzcGVudCB1cG9uIHRoZSBlbWFpbCA/DQoJPCAyIA0KCQl0byBiZSBvbiBuZXh0IHBoYXNlIA0KYWdlIG9mIG9wZW4gDQoNCg0KdmVyc2lvbiBvbiBocmVmIGNsaWNrIGEgbnVtYmVyIHNvcnQgb2YgdG8gYmUgc2VudCANCg==" }

              ]
              }
             }'

def json_email(json_scenarios)
@sheet.add_row
@i=@i+1

@sheet.rows[@i].add_cell json_scenarios, :style=> @style
  # REST CLIENT INPUTS
  json_hash = JSON.parse(json_scenarios)
  puts json_hash
  rest_client_email_subject        = json_hash['message']['subject']
  rest_client_email_body           = json_hash['message']['text']
  rest_client_from_email           = json_hash['message']['fromEmail']
  rest_client_from_delivery_name   = json_hash['message']['fromName']
  rest_client_mtag                 = json_hash['message']['mtag']['mtag1']
  rest_client_reply_to_email       = json_hash['message']['replyTo']
  rest_client_recipient_email      = json_hash['message']['recipient']
  rest_client_username             = json_hash['userName']
  rest_client_password             = json_hash['password']


  # POSTING REQUEST ON REST CLIENT
  json_output = RestClient.post 'http://10.20.50.69:18080/sendEmail',
                                 json_scenarios,
                                 :content_type => 'application/json'

  puts "#RESTCLIENT RESPONSE SHOWN AS PER THE GIVEN POST REQUEST:\n #{json_output}" # RESTCLIENT POST RESPONSE
  json_output.headers
  json_output.headers.class
  json_output.headers['messageId']
  json_output.code
  rest_client_output =JSON.parse(json_output) # CONVERTING JSON RESPONSE TO HASH
  rest_client_message_id          = rest_client_output['messageId']
  rest_client_message_status      = rest_client_output['requestStatus']
  rest_client_message_status_code = rest_client_output['statusCode']
  rest_client_message_status_desc = rest_client_output['statusDesc']
  rest_client_message_cust_ref    = rest_client_output['custRef']
    # CHECKING RESTCLIENT STATUS CODE
    case
    when rest_client_message_status_code == "201"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "202"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "204"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "205"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "206"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "207"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "208"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "209"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "210"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    when rest_client_message_status_code == "211"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
    else rest_client_message_status_code == "200"
      puts "Status Code :#{rest_client_message_status_code} and Status Description : #{rest_client_message_status_desc}"
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_code}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_message_status_desc}", :style=> @style
      puts "Rest client Message Id : #{rest_client_message_id}"
    end
  #RESTCLIENT OUTPUT AS HASH
  rest_client_hash = {:mid               => rest_client_message_id,
                      :status_code       => rest_client_message_status_code,
                      :message_status    => rest_client_message_status,
                      :status_desc       => rest_client_message_status_desc,
                      :from_email        => rest_client_from_email,
                      :mail_subject      => rest_client_email_subject,
                      :reply_to_email    => rest_client_reply_to_email,
                      :recipient_email   => rest_client_recipient_email,
                      :mtag              => rest_client_mtag
                     }
  return (rest_client_hash)
end

def database(rest_client_hash)
  sleep 2
  # DATABASE VERIFICATION
  if rest_client_hash[:status_code] == "200"
    # VERIFYING API ENTRY ON DATABASE
    db_login = Mysql2::Client.new(:host => $db_host_address, :username => $db_username,:password=> $db_password, :database => 'email_billing')
    db_output = db_login.query("select * from email_billing.email_billing where MID= '#{rest_client_hash[:mid]}'")
    database_output = db_output.first     # CONVERTING DATABASE RESPONSE TO HASH
    unless database_output.nil? || database_output == 0
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
      puts "\n#DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON MESSAGE ID:\n #{database_output}"
      puts "Database Message Id : #{database_message_id}"
	  @sheet.rows[@i].add_cell "DATABASE RESPONSE SHOWN ON QUERY SEARCH BASED ON MESSAGE ID #{database_message_id}"
      db_login.close 
    else
       puts 'Database Query is Invalid or Data is not Inserted in Billing Table or Restclient Error Response'
	   @sheet.rows[@i].add_cell 'Database Query is Invalid or Data is not Inserted in Billing Table or Restclient Error Response'
    end

    # VERIFICATION OF RESTCLIENT OUTPUTS WITH DATABASE OUTPUTS
    if rest_client_hash[:mid] = database_message_id
      puts "Rest Client message id : #{rest_client_hash[:mid]} matches with Database message Id: #{database_message_id}"
	  @sheet.rows[@i].add_cell "#{database_message_id}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:mid]}", :style=> @style
	  @sheet.rows[@i].add_cell "PASS", :style=> @style
    else
      puts "Rest Client message id : #{rest_client_hash[:mid]} mismatches with Database message Id: #{database_message_id}"
	  @sheet.rows[@i].add_cell "#{database_message_id}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:mid]}", :style=> @style
	  @sheet.rows[@i].add_cell "FAIL", :style=> @style
    end

    if rest_client_hash[:mail_subject] = database_message_subject
      puts "Rest Client subject : #{rest_client_hash[:mail_subject]} matches with Database Email Subject :#{database_message_subject}"
	  @sheet.rows[@i].add_cell "#{database_message_subject}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:mail_subject]}", :style=> @style
	  @sheet.rows[@i].add_cell "PASS", :style=> @style
    else
      puts "Rest Client subject : #{rest_client_hash[:mail_subject]} mismatches with Database Email Subject :#{database_message_subject}"
	  @sheet.rows[@i].add_cell "#{database_message_subject}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:mail_subject]}", :style=> @style
	  @sheet.rows[@i].add_cell "FAIL", :style=> @style
    end

    if rest_client_hash[:recipient_email] = database_to_recipient_address
      puts "Rest Client Recipient Email Address : #{rest_client_hash[:recipient_email]} matches with Database Recipient Email Address : #{database_to_recipient_address}"
	  @sheet.rows[@i].add_cell "#{database_to_recipient_address}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:recipient_email]}", :style=> @style
	  @sheet.rows[@i].add_cell "PASS", :style=> @style
	else
      puts "Rest Client Recipient Email Address : #{rest_client_hash[:recipient_email]} mismatches with Database Recipient Email Address : #{database_to_recipient_address}"
      @sheet.rows[@i].add_cell "#{database_to_recipient_address}", :style=> @style
	  @sheet.rows[@i].add_cell "#{rest_client_hash[:recipient_email]}", :style=> @style
	  @sheet.rows[@i].add_cell "FAIL", :style=> @style
	end

    if rest_client_hash[:mtag] = database_mtag
      puts "Rest Client Recipient Email Address : #{rest_client_hash[:mtag]} matches with Database Mtag : #{database_mtag}"
#	    @sheet.rows[@i].add_cell "#{database_mtag}", :style=> @style
#	    @sheet.rows[@i].add_cell "#{rest_client_hash[:mtag]}", :style=> @style
#	    @sheet.rows[@i].add_cell "PASS", :style=> @style
    else
      puts "Rest Client Recipient Email Address : #{rest_client_hash[:mtag]} mismatches with Database Mtag : #{database_mtag}"
#	    @sheet.rows[@i].add_cell "#{database_mtag}", :style=> @style
#	    @sheet.rows[@i].add_cell "#{rest_client_hash[:mtag]}", :style=> @style
#	    @sheet.rows[@i].add_cell "FAIL", :style=> @style
    end
  end
end

def gmail(rest_client_hash)
  # CONNECTING GMAIL AND CHECKING MAILS
  gmail_login = Gmail.connect($gmail_username, $gmail_password)
  if gmail_login.logged_in?
    puts "\n#RETRIVING API RESPONSE THROUGH MAILS"
    puts "Gmail Logged in successfully for the User : #{$gmail_username}"
    gmail_from_address = gmail_login.inbox.emails(:subject => rest_client_hash[:mail_subject])[0].message.from.to_s
    # CHECKS IF RECEIPIENT MAIL HAS ANY ATTACHMENTS
    if gmail_login.inbox.emails(:subject => rest_client_hash[:mail_subject])[0].message.has_attachments?
      puts "The Mail Sent is shown with Attachments"
    else
      puts "The Gmail Received is shown without attachments"
    end
    gmail_body_content = gmail_login.inbox.emails(:subject => rest_client_hash[:mail_subject])[0].message.body
    gmail_subject = gmail_login.inbox.emails(:subject => rest_client_hash[:mail_subject])[0].message.subject
    puts "Filtered Mails Based on the subject : #{rest_client_hash[:mail_subject]}"
    gmail_login.logout
  else
    puts "Gmail Login Credentials is Invalid or unable to login to gmail"
  end
end

# Verification of successful Plain email delivery without attachment
puts "### SCENARIO 1: VERIFICATION OF PLAIN EMAIL DELIVERY ###"
rest_client_output_scenario_1 = json_email(json_scenario_1)
puts database(rest_client_output_scenario_1)
# Verification of successful Plain email delivery with attachment
puts "### SCENARIO 2: VERIFICATION OF PLAIN EMAIL DELIVERY WITH ATTACHMENT ###"
rest_client_output_scenario_2 = json_email(json_scenario_2)
puts database(rest_client_output_scenario_2)
# Verification of email with template configured in user template
puts "### SCENARIO 3: VERIFICATION OF EMAIL DELIVERY WITH USER CONFIGURED TEMPLATE ###"
rest_client_output_scenario_3 = json_email(json_scenario_3)
puts database(rest_client_output_scenario_3)
# Verification of email with m-tag
puts "### SCENARIO 4: VERIFICATION OF EMAIL DELIVERY WITH M-TAG ###"
rest_client_output_scenario_4 = json_email(json_scenario_4)
puts database(rest_client_output_scenario_4)
# Verification of email with template with plain body
puts "### SCENARIO 5: VERIFICATION OF EMAIL DELIVERY WITH PLAIN BODY TEMPLATE ###"
rest_client_output_scenario_5 = json_email(json_scenario_5)
puts database(rest_client_output_scenario_5)
# Verification of email with template with HTML body
puts "### SCENARIO 6: VERIFICATION OF EMAIL DELIVERY WITH HTML BODY ###"
rest_client_output_scenario_6 = json_email(json_scenario_6)
puts database(rest_client_output_scenario_6)
# Verification of email subject Length Validation
puts "### SCENARIO 7: VERIFICATION OF EMAIL SUBJECT LENGTH VALIDATION ###"
rest_client_output_scenario_7 = json_email(json_scenario_7)
puts database(rest_client_output_scenario_7)
# Verification of email body length Validation
puts "### SCENARIO 8: VERIFICATION OF EMAIL BODY LENGTH VALIDATION ###"
rest_client_output_scenario_8 = json_email(json_scenario_8)
puts database(rest_client_output_scenario_8)
# Verification of Invalid Username / Password
puts "### SCENARIO 9: VERIFICATION OF INVALID USERNAME /PASSWORD ###"
rest_client_output_scenario_9 = json_email(json_scenario_9)
puts database(rest_client_output_scenario_9)
# Verification of Invalid source address / reply to / recipient
puts "### SCENARIO 10: VERIFICATION OF INVALID SOURCE ADDRESS/ REPLY TO/ RECIPIENT ###"
rest_client_output_scenario_10 = json_email(json_scenario_10)
puts database(rest_client_output_scenario_10)
# Verification of Account Deactivation
puts "### SCENARIO 11: VERIFICATION OF ACCOUNT DEACTIVATION ###"
rest_client_output_scenario_11 = json_email(json_scenario_11)
puts database(rest_client_output_scenario_11)
# Verification of Credit Expired
puts "### SCENARIO 12: VERIFICATION OF EXPIRED CREDITs ###"
rest_client_output_scenario_12 = json_email(json_scenario_12)
puts database(rest_client_output_scenario_12)
# Verification of Email media not assigned
puts "### SCENARIO 13: VERIFICATION OF EMAIL MEDIA NOT ASSIGNED ###"
rest_client_output_scenario_13 = json_email(json_scenario_13)
puts database(rest_client_output_scenario_13)
# Verification of Invalid template id
puts "### SCENARIO 14: VERIFICATION OF INVALID TEMPLATE ID ###"
rest_client_output_scenario_14 = json_email(json_scenario_14)
puts database(rest_client_output_scenario_14)
# Verification of No Credit available
puts "### SCENARIO 15: VERIFICATION OF NO AVAILABLE CREDITS ###"
rest_client_output_scenario_15 = json_email(json_scenario_15)
puts database(rest_client_output_scenario_15)
# Verification of  from email id  configuration
puts "### SCENARIO 16: VERIFICATION OF FROM EMAIL ID ###"
rest_client_output_scenario_16 = json_email(json_scenario_16)
puts database(rest_client_output_scenario_16)
# Verification of  reply to email id  configuration
puts "### SCENARIO 17: VERIFICATION OF REPLY TO EMAIL ID ###"
rest_client_output_scenario_17 = json_email(json_scenario_17)
puts database(rest_client_output_scenario_17)
# Verification of successful  email delivery with multiple attachment
puts "### SCENARIO 18: VERIFICATION OF EMAIL DELIVERY WITH MULTIPLE ATTACHMENTS ###"
rest_client_output_scenario_18 = json_email(json_scenario_18)
sleep 5
puts database(rest_client_output_scenario_18)
# Verification of successful  email delivery with multiple attachment
#puts "### SCENARIO 19: VERIFICATION OF EMAIL DELIVERY WITH GMAIL ###"
#rest_client_output_scenario_19 = json_email(json_scenario_19)
#puts database(rest_client_output_scenario_19)
#puts gmail(rest_client_output_scenario_19)
# @sheet.column_widths *([50]*@sheet.column_info.count)
@sheet.column_widths 80
@p.serialize "D:/Result#{Time.now.strftime('%m%d%y%H%M%S')}.xlsx"