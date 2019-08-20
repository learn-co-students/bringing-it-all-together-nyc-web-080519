class Dog

    attr_accessor :id, :name, :breed

    def initialize(:id = nil, :name, :breed)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = << -SQL
            CREATE TABLE dogs IF EXISTS NOT
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = << -SQL
            DROP TABLE dogs
        SQL
    end 

    def new_from_db

    end

    def find_by_name

    end 

    def update

    end

    def save

    end 

end