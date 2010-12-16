require 'sequel'
begin
    db = Sequel.connect('mysql://root@localhost/my_db')
rescue Sequel::AdapterNotFound => ex
    puts 'rescue'
    raise ex
end
res = db['select * from users']
res.each do |row|
    p row
    col1 = row[0]
    col2 = row[1]
end
