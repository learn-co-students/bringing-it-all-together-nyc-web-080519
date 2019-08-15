class Dog

    attr_accessor :name
    attr_reader :id, :breed

    def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @breed = attributes[:breed]
    end

    def self.create_table
        DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);')
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs;')
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.create(attributes)
        dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
        dog.save
        dog
    end

    def self.find_by_id(id)
        db_result = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?;', id)[0]
        dog = Dog.new(id: db_result[0], name: db_result[1], breed: db_result[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            AND breed = ?
            LIMIT 1;
        SQL
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
        else
            dog = Dog.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? LIMIT 1;', name)
        dog.map{|r| Dog.new_from_db(r)}[0]
    end

    def save
        if self.id
            self.update
        else
            sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?);'
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
        end
        self
    end

    def update
        sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?;'
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end # end of Dog class