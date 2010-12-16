require 'yaml'
require 'sequel'
require 'digest/md5'
require 'nestful'

class PasswordReset


    def initialize(args)

        args.each_with_index do |a, i|
            if a == '-config'
                @config_file = args[i+1]
            end
        end
        if !@config_file
            puts "You must specify the -config option."
            exit 1
        end
        puts 'Config file: ' + @config_file.to_s
        @config = YAML.load(File.open(@config_file))
        p @config.inspect

        @database = @config["database"]
        @table    = @config["table"]
        @adapter  = @database["adapter"]
        begin
            @db = Sequel.connect("#{@adapter}://#{@config["database"]["username"]}:#{@config["database"]["password"]}@#{@config["database"]["host"]}/#{@config["database"]["dbname"]}")
        rescue Sequel::AdapterNotFound => ex
            puts "Database not supported: #{@adapter}: #{ex.message}"
            exit 1
        end

        @options   = @config["options"] || {}
        @callbacks = @config["callbacks"] || {}

        if @options["do_reset"]
            puts 'Passwords WILL BE RESET!'
            if @options["hash_password"]
                puts 'Passwords will be MD5 hashed before being stored.'
            end
        else
            puts 'Passwords will not be reset, you should reset them in the callbacks.'
        end

        if @callbacks["on_match_url"]
            puts "#{@callbacks["on_match_url"]} will be called on every matching email."
        end


    end

    def load_emails_and_usernames
        @emails    = {}
        @usernames = {}
        load_file("emails.txt", @emails, :gsub=>{"::a::t::"=>"@"})
        load_file("usernames.txt", @usernames)

    end

    def load_file(fname, hash, options={})
        i = 0
        File.open(fname, "r") do |infile|
            while (line = infile.gets)
                line = line.strip
                line = line.downcase unless @options["case_sensitive_match"]
                if options[:gsub]
                    options[:gsub].each_pair do |k, v|
                        line = line.gsub(k, v)
                    end
                end
                hash[line] = line
                i          += 1
#                break if i > 50
            end
        end
    end

    def before_run

    end

    def run
        before_run

        load_emails_and_usernames

        @users = @db.from(:users)

        res = @db["select * from #{@table["name"]}"]
        res.each do |row|
#            p row
            email    = row[:email]
            username = row[:username]
#            p email
            if email_compromised(email)
                puts "Email compromised: #{email}"
                reset_and_callbacks(row, :email=>email)
            elsif username_compromised(username)
                puts "Email compromised: #{username}"
                reset_and_callbacks(row, :username=>username)
            end

        end

        after_run
    end


    def reset_and_callbacks(row, compromised)
        newpass = reset_password(row)
        do_callback("on_match_url", row, newpass, compromised)
    end

    def reset_password(row)
        if @options["do_reset"]
            newpass     = random_string
            pass_to_use = newpass
            if @options["hash_password"]
                newpass_hashed = hash_password(newpass)
                pass_to_use    = newpass_hashed
            end
            puts "updating row #{row[@table["id_column"].to_sym]}'s password to #{pass_to_use}"
            @users.filter('id = ?', row[@table["id_column"].to_sym]).update(@table["password_column"] => pass_to_use)
        end
        newpass
    end

    def do_callback(which, row, newpass, compromised)
        if @callbacks[which]
            params = compromised
            params.merge!(:newpass=>newpass) if newpass
            Nestful.post @callbacks[which], :params=>params
        end
    end

    # override this to implement your own hashing algorithm
    def hash_password(newpass)
        Digest::MD5.hexdigest(newpass)
    end

    def email_compromised(email)
        !@emails[email].nil?
    end

    def username_compromised(username)
        !@usernames[username].nil?
    end


    def random_string(length=10)
        chars    = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
        password = ''
        length.times { password << chars[rand(chars.size)] }
        password
    end


    def after_run

    end

end

