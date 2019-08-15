class Dog
    attr_accessor :id, :name, :breed

    # when looking for attributes at initalize,
    # use a hash (metaprogramming mod ?) as args
    # also note that when args are set, we should
    # set it as "arg:" so like 
    # def method(arg:) example
    def initialize(name:, breed:, id: nil)
        @name, @breed, @id = name, breed, id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    # when we are saving, we need to INSERT INTO:
    # if it does not have an id, it means that it is
    # not in the DB
    # if it does have an id, we just need to update it

    # specs-wise * we can just return self to get the
    # GREEN (specs are asking to return an instance of the dog class,
    # and save the instance then set the given dogs attr with the id)

    #but what we also want to do:
        # if have the id, we want to update the database
            # create a conditional...
            # if the dog is in the database(checking by the id)
            # all we need to do is update the database with all
            # the attributes of self. :)
    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs(name , breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            id_sql = <<-SQL
                SELECT last_insert_rowid()
                FROM dogs
            SQL
            @id = DB[:conn].execute(id_sql).flatten.first
            self
        end
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(name: name, breed: breed, id: id)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        # row = DB[:conn].execute(sql, id).flatten
        row = DB[:conn].execute(sql, id).flatten.first
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end


    # find the dog in the database
    # if it is not empty, we create a dog instance
    # if it is empty, we create it and insert it
    # into the DB
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? 
            AND breed = ?
            LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog

        # if !dog.empty?
        #     new_dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
        # else
        #     new_dog = self.create(name: name, breed: breed)
        # end
        
        # new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name).flatten
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end


    # DONT FORGET UPDATE table SET values... etc
    # need to go syntax
    def update
        sql = <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end