class Dog
    attr_accessor :name
    attr_reader :id, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
       DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)") 
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.new_from_db(dog_arr)
        id = dog_arr[0]
        name = dog_arr[1]
        breed = dog_arr[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_name(name)
        sql = <<-SQL 
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_instance = dog[0]
            dog = Dog.new(id: dog_instance[0], name: dog_instance[1], breed: dog_instance[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def save
        if self.id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
       Dog.find_by_id(self.id) 
        # self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

end