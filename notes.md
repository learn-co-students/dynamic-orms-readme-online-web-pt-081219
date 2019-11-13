require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class Song
#build method that grabs table name
#require 'active_support/inflector' this piece of code makes it so 
#you can use the .pluralize method. 

  def self.table_name
    self.to_s.downcase.pluralize
  end

#build method that grabs column names
#PRAGMA returns an array of hashes describing the table
#each hash is one column
  def self.column_names
    DB[:conn].results_as_hash = true #turns results into a hash

    sql = "pragma table_info('#{table_name}')" 
    #returns an array of hashes from given table

    table_info = DB[:conn].execute(sql) #runs the sql
    column_names = [] #make an empty array 
    table_info.each do |row| #iterate over the array of hashes 
      column_names << row["name"] #grab each hashes name and put it in an array column_names
    end
    column_names.compact #gets rid of all nil values
    #the result will be ["id", "name", "album"]
  end
    #itterate over column name array 
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
    #set an attr_acessor with each column name turned into a symbol
  end
#define our method to take in an argument of options which defaults to an empty hash
#we expect new to be called with a hash, so when we refer to options inside initialize 
#we expect to be operating on a hash
  def initialize(options={})
  #iterate over the options hash and use our send method 
  #.send invokes a method without knowing what the method name is
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
#using a class method inside an instance method
#to acsess the table name we want to INSERT into from inside our method 
#abstracting table name
  def table_name_for_insert
    self.class.table_name
  
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
       #push the return value of invoking a method via the #send method, unless that value is nil 
       #each value will be wrapped in '' because the returning value should look like 'example'
       #SQL expects us to pass in each column value in single quotes.
       #this will return ["'the name of the song'", "'the album of the song'"]
    end
    values.join(", ")
    binding.pry
    #We need comma separated values for our SQL statement. Let's join this array into a string:
    #this would return "'name','album'"
  end
#abstracting column names 
#need to remove id because that is assigned in SQL
#this would return ["name","album"]
#the results need to be a comma seperated string so we add .join(", ")
#this will return "name, album" 
  def col_names_for_insert
    new = self.class.column_names.delete_if {|col| col == "id"}.join(", ")
   
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end