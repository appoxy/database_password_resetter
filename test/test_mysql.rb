require 'mysql'
my = Mysql::new("localhost", "root", "", "test")
res = my.query("select * from users")
res.each do |row|
    p row
    col1 = row[0]
    col2 = row[1]
end
