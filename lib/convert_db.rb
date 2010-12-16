class Converter

    def run
        counter = 0

        begin

            emails    = []
            usernames = []

            File.open("parsed_db.txt", "r") do |infile|
                while (line = infile.gets)
                    line     = line.strip
#            puts "#{counter}: #{line}"
                    split    = line.split(":::")
#            p split
                    username = split[0].strip
                    password = split[1].strip
                    email    = split[2].strip

                    emails << email
                    usernames << username

                    counter = counter + 1
                    if counter % 1000 == 0
                        puts "#{counter}"
                    end
                end
            end

            puts "sorting..."
            emails.sort!
            usernames.sort!

            puts "writing..."
            email_file    = File.new("emails.txt", "w")
            username_file = File.new("usernames.txt", "w")
            begin
                emails.each do |e|
                    email_file.puts obfuscate(e)
                end
                email_file.close

                usernames.each do |u|
                    username_file.puts u
                end
                username_file.close

            end

        end
    end

    def obfuscate(e)
        # pretty weak, but better than nothing?
        e.gsub("@", "::a::t::")
    end

end

Converter.new.run
