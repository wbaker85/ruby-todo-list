require 'bundler/setup'

require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/todolist'

class TodoListTest < MiniTest::Test
  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  def test_to_a
    assert_equal(@todos, @list.to_a)
  end

  def test_size
    assert_equal(3, @list.size)
  end

  def test_first
    assert_equal(@todo1, @list.first)
  end

  def test_last
    assert_equal(@todo3, @list.last)
  end

  def test_shift
    assert_equal(@todo1, @list.shift)
    assert_equal(@todos[1..-1], @list.to_a)
  end

  def test_pop
    assert_equal(@todo3, @list.pop)
    assert_equal(@todos[0..-2], @list.to_a)
  end

  def test_done?
    assert_equal(false, @list.done?)
    @list.each { |todo| todo.done! }
    assert_equal(true, @list.done?)
  end

  def test_type_error
    assert_raises(TypeError) { @list.add([]) }
    assert_raises(TypeError) { @list.add('asdf') }
  end

  def test_shovel
    new_todo = Todo.new('something')
    @list << new_todo
    @todos << new_todo
    assert_equal(@todos, @list.to_a)
  end

  def test_add
    new_todo = Todo.new('something')
    @list.add(new_todo)
    @todos << new_todo
    assert_equal(@todos, @list.to_a)
  end

  def test_item_at
    assert_equal(@todos[1], @list.item_at(1))
    assert_raises(IndexError) { @list.item_at(100) }
  end

  def test_mark_done_at
    @todos[1].done!
    @list.mark_done_at(1)

    assert_equal(@todos, @list.to_a)
    assert_raises(IndexError) { @list.mark_done_at(100) }
  end

  def test_done!
    @todos.each(&:done!)
    @list.done!

    assert_equal(@todos, @list.to_a)
  end

  def test_mark_undone_at
    @todos.each(&:done!)
    @todos[1].undone!

    @todos.each(&:done!)
    @list.mark_undone_at(1)

    assert_equal(@todos, @todos.to_a)
    assert_raises(IndexError) { @list.mark_undone_at(100) }
  end

  def test_remove_at
    @todos.delete_at(1)
    @list.remove_at(1)

    assert_equal(@todos, @list.to_a)
    assert_raises(IndexError) { @list.remove_at(100) }
  end

  def test_to_s
    output = <<~OUTPUT.chomp
    --- Today's Todos ---
    [ ] Buy milk
    [ ] Clean room
    [ ] Go to gym
    OUTPUT
  
    assert_equal(output, @list.to_s)
  end

  def test_to_s_with_one_done
    @list.mark_done_at(1)

    output = <<~OUTPUT.chomp
    --- Today's Todos ---
    [ ] Buy milk
    [X] Clean room
    [ ] Go to gym
    OUTPUT
  
    assert_equal(output, @list.to_s)
  end

  def test_to_s_with_all_done
    @list.done!

    output = <<~OUTPUT.chomp
    --- Today's Todos ---
    [X] Buy milk
    [X] Clean room
    [X] Go to gym
    OUTPUT
  
    assert_equal(output, @list.to_s)
  end

  def test_each
    test_arr = []
    @list.each { |todo| test_arr << todo }
    assert_equal(@todos, test_arr)
  end

  def test_select
    @list.mark_done_at(0)
    assert_equal(@todos[1..-1], @list.select { |todo| !todo.done? }.to_a)
  end

  def test_find_by_title
    assert_equal(@todos[0], @list.find_by_title(@todos[0].title))
    assert_equal(@todos[1], @list.find_by_title(@todos[1].title))
  end

  def test_all_done
    @list.mark_done_at(1)
    assert_equal([@todos[1]], @list.all_done.to_a)
  end

  def test_all_not_done
    @list.mark_done_at(1)
    assert_equal([@todos[0], @todos[2]], @list.all_not_done.to_a)
  end

  def test_mark_done
    @list.mark_done(@todos[0].title)
    assert_equal([@todos[0]], @list.all_done.to_a)
  end

  def test_mark_all_done
    @list.mark_all_done
    @todos.each(&:done!)
    assert_equal(@todos, @list.to_a)
  end

  def test_mark_all_undone
    @list.mark_all_done
    @list.mark_all_undone
    assert_equal(@todos, @list.to_a)
  end

end