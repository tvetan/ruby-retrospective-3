class TodoList
  include Enumerable
  attr_accessor :collection

  def initialize(collection = [])
    @collection = collection
  end

  def self.parse(text)
    rows = text.lines.map { |row| row.split("|").map(&:strip) }
    todos = rows.map do |status, description, priority, tags|
      ToDo.new(status, description, priority, tags)
    end

    TodoList.new(todos)
  end

  def filter(criteria)
    filtered_todo_list = @collection.select do |todo|
      criteria.filter_criteria todo
    end

    TodoList.new(filtered_todo_list)
  end

  def each
    collection.each{ |todo| yield todo }
  end

  def adjoin(other)
   TodoList.new(collection.concat other.collection)
  end

  def tasks_todo
    count { |todo| todo.status == :todo }
  end

  def tasks_in_progress
    count { |todo| todo.status == :current }
  end

  def tasks_completed
    count { |todo| todo.status == :done }
  end

  def completed?
    all? { |todo|  todo.status == :done }
  end
end

class ToDo
  def initialize(status, description, priority, tags)
    @status = status.downcase.to_sym
    @description = description
    @priority = priority.downcase.to_sym
    @tags = tags.split(",").map(&:strip)
  end

  def status
    @status
  end

  def description
    @description
  end

  def priority
    @priority
  end

  def tags
    @tags
  end
end

class Criteria
  def self.status(status)
    StatusCriteria.new(status)
  end

  def self.priority(current_priority)
    PriorityCriteria.new(current_priority)
  end

  def self.tags(tags)
    TagsCriteria.new(tags)
  end

  def |(other)
    Disjunction.new self, other
  end

  def &(other)
    Conjunction.new self, other
  end

  def !
    Negation.new self
  end
end

class StatusCriteria < Criteria
  def initialize(status)
    @status = status
  end

  def filter_criteria(todo)
    todo.status == @status
  end
end

class PriorityCriteria < Criteria
  def initialize(priority)
    @priority = priority
  end

  def filter_criteria(todo)
    todo.priority == @priority
  end
end

class TagsCriteria < Criteria
  def initialize(tags)
    @tags_criteria = tags
  end

  def filter_criteria(todo)
    @tags_criteria.all? { |tag| todo.tags.include? tag  }
  end
end

class Disjunction < Criteria
  def initialize(first, second)
    @first = first
    @second = second
  end

  def filter_criteria(todo)
    @first.filter_criteria todo or @second.filter_criteria todo
  end
end

class Conjunction < Criteria
  def initialize(first, second)
    @first = first
    @second = second
  end

  def filter_criteria(todo)
    @first.filter_criteria todo and @second.filter_criteria todo
  end
end

class Negation < Criteria
  def initialize(first)
    @first = first
  end

  def filter_criteria(todo)
    not @first.filter_criteria todo
  end
end