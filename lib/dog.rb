class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        return self
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        new_dog = Dog.new({name: name, breed: breed})
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL

        row = DB[:conn].execute(sql, name, breed)[0]
        if row
            Dog.new_from_db(row)
        else
            Dog.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(row)
    end
end