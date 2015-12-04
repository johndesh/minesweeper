class Tile
  DELTAS = [
    [-1, -1],
    [-1,  0],
    [-1,  1],
    [ 0, -1],
    [ 0,  1],
    [ 1, -1],
    [ 1,  0],
    [ 1,  1]
  ]

  attr_reader :pos

  def initialize(board, pos)
    @board, @pos = board, pos

    @bombed, @explored, @flagged = [false] * 3


    create_methods
  end

  def bomb
    @bombed = true
  end

  def explore
    return self if flagged? || explored?

    @explored = true

    neighbors.each(&:explore) unless neighbor_bomb_count > 0 || bombed?

    self
  end

  def flag
    @flagged = true
  end

  def neighbors
    DELTAS.map do |dx, dy|
      adjacent_pos = [dx + pos[0], dy + pos[1]]

      @board[adjacent_pos]

    end.compact
  end

  def neighbor_bomb_count
    neighbors.count(&:bombed?)
  end

  def render
    if flagged?
      'F'
    elsif explored?
      neighbor_bomb_count == 0 ? ' ' : neighbor_bomb_count.to_s
    else
      '*'
    end
  end

  private
  def create_methods
    %w(bombed? flagged? explored?).each do |method_name|
      var_name = method_name.chop.prepend('@').to_sym

      self.class.send(:define_method, method_name.to_sym) do
        instance_variable_get(var_name)
      end
    end
  end
end

class Board
  attr_reader :grid_size, :bomb_count

  def initialize(grid_size, bomb_count)
    @grid_size, @bomb_count = grid_size, bomb_count

    generate_grid
  end

  def [](pos)
    return nil unless in_range?(pos)

    row, col = pos

    @grid[row][col]
  end

  def in_range?(pos)
    pos.none? { |axis| axis < 0 || axis >= grid_size }
  end

  def lost?
    @grid.flatten.any? { |tile| tile.explored? == tile.bombed? }
  end

  def reveal
    @grid.map do |row|

      row.map { |tile| tile.render }
    end
  end

  def won?
    @grid.flatten.all? { |tile| tile.explored? != tile.bombed? }
  end

  private
  def generate_grid
     @grid = Array.new(grid_size) do |row|
       Array.new(grid_size) { |col| Tile.new(self, [row, col]) }
     end

     fill_grid
  end

  def fill_grid
    bomb_count.times do
      rand_pos = Array.new(2) { rand(grid_size) }

      self[rand_pos].bomb
    end
  end

end
