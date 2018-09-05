require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end 

  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless questions.length > 0

    Question.new(questions.first) # question is stored in an array!
  end
  
  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    
    questions.map { |question| Question.new(question)}
  end
  
  def author
    User.find_by_id(self.author_id)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
end

class Reply
  attr_accessor :question_id, :reply_id, :user_id, :body
  attr_reader :id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end 

  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless replies.length > 0

    Reply.new(replies.first) # question is stored in an array!
  end
  
  def self.find_by_user_id(user_id) 
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    
    replies.map { |reply| Reply.new(reply)}
  end 
  
  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    
    replies.map { |reply| Reply.new(reply)}
  end 
  
  def author
    User.find_by_id(self.user_id)
  end
  
  def question
    Question.find_by_id(self.question_id)
  end
  
  def parent_reply 
    return nil if self.reply_id.nil?
    Reply.find_by_id(self.reply_id)
  end 
  
  def child_replies
    all_replies = Reply.find_by_question_id(self.question_id) 
    all_replies.select { |reply| reply.reply_id == self.id } 
  end 
  
end

class User
  attr_accessor :fname, :lname
  attr_reader :id 
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end 

  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless users.length > 0

    User.new(users.first) # question is stored in an array!
  end
  
  def self.find_by_name(fname, lname) 
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless users.length > 0

    users.map { |user| User.new(user)}
  end 
  
  def authored_questions
    Question.find_by_author_id(self.id)
  end 
  
  def authored_replies
    Reply.find_by_user_id(self.id)
  end 
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
end

class QuestionFollow
  attr_accessor :question_id, :user_id 
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end
  
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end 
  
  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
        JOIN question_follows 
        ON question_follows.user_id = users.id 
      WHERE
        question_id = ?
    SQL
    return nil unless users.length > 0
    
    users.map { |user| User.new(user) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
        JOIN question_follows 
        ON question_follows.question_id = questions.id 
      WHERE
        user_id = ?
    SQL
    return nil unless questions.length > 0
    
    questions.map { |question| Question.new(question) }
  end 
  
  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
      JOIN question_follows
      ON question_follows.question_id = questions.id
    GROUP BY
      question_id
    ORDER BY
      COUNT(*) DESC
      LIMIT ?
    SQL
    return nil unless questions.length > 0
    
    questions.map {|question| Question.new(question)}
  end
end

class QuestionLike 
  attr_accessor :question_id, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end
  
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end 
  
  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
        JOIN question_likes
        ON question_likes.user_id = users.id 
      WHERE
        question_id = ?
    SQL
    return nil unless users.length > 0
    
    users.map { |user| User.new(user) }
  end
  
  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
      COUNT(*)
      FROM 
        users 
        JOIN question_likes 
        ON question_likes.user_id = users.id 
      WHERE 
        question_id = ? 
    SQL
      
    likes   
  end 
  
  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
        JOIN question_likes 
        ON question_likes.question_id = questions.id 
      WHERE
        user_id = ?
    SQL
    return nil unless questions.length > 0
    
    questions.map { |question| Question.new(question) }
  end 
  
end 