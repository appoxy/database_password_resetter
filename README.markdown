Database Password Reset Script
==============================

Due to the Gawker password fiasco, we thought we'd share the script we're using to reset
passwords so everyone can easily reset any password where the email is found in the gawker list.

Brought to you by: [![Appoxy](http://www.simpledeployr.com/images/global/appoxy-small.png)](http://www.appoxy.com)

**IMPORTANT NOTICE: You will need the list of usernames and emails that were compromised in the Gawker hack.**

Due to privacy/security concerns, we will not publish the username/email list to the public. We know this is kind
of a pain, but we don't want to be the ones spreading spam love around.

**You can get this list from us by [filling out this form](https://spreadsheets.google.com/viewform?formkey=dDJkVFhXaG1GWnNZNWptY21qMmJkLWc6MQ).**

Installation
------------

You must have Ruby 1.9+ installed and install the following ruby gems:

    gem install sequel nestful

To run script, type at command line:

    ruby run_reset.rb -config config.yml

Config
------

Modify config.yml with the appropriate settings.

### Database

database section is self explanatory.

### Table

table section is also somewhat self explanatory.

One or both of the following must be present.

- email_column: name of the column that contains the email addresses.
- username_column: name of the column that contains usernames.
- id_column: Used during the update operation when password is being set. Only required if do_reset is true.


### Options

- do_reset: true if you want the script to generate a random password and set it. Default is false.
- hash_password: if do_reset is true and this is true, the password will be hashed before being stored.
- case_sensitive_match: if true, matching will be case sensitive. Default is false.

### callbacks / webhooks

- on_match_url will POST to this URL with the matching email address. This can be used to send out an email with information on the reset. If do_reset is set above, the new password will also be send to this URL.


Advanced
--------

To implement more advanced features, you'll need to write some code.

First thing is to write a class that extends PasswordReset.

### Custom Password Hashing

Override hash_password method.

    def hash_password(row)

Row contains a hash of the database row.




