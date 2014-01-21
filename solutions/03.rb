module Graphics
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def draw(canvas)
      canvas.set_pixel(@x, @y)
    end

    def eql? (other_point)
      @x.eql?(other_point.x) and @y.eql? (other_point.y)
    end

    alias == eql?

    def hash
      @x.hash & @y.hash
    end
  end

  class Line
    attr_reader :first_point, :second_point

    def initialize(first_point,second_point)
      @first_point, @second_point = first_point, second_point
    end

    def from
      if @first_point.x == @second_point.x
        return @first_point.y > @second_point.y ? @second_point : @first_point
      end

      return @first_point.x > @second_point.x ? @second_point : @first_point
    end

    def to
      if @first_point.x == @second_point.x
        return @first_point.y < @second_point.y ? @second_point : @first_point
      end

      return @first_point.x < @second_point.x ? @second_point : @first_point
    end

    def eql? (other_line)
      is_first_equal_first = @first_point.eql?(other_line.first_point)
      is_second_equal_second = @second_point.eql?(other_line.second_point)
      is_first_equal_second = @first_point.eql?(other_line.second_point)
      is_second_equal_first = @second_point.eql?(other_line.first_point)

      (is_first_equal_first and is_second_equal_second) or
      (is_first_equal_second and is_second_equal_first)
    end

    alias == eql?

    def hash
      @first_point.hash & @second_point.hash
    end

    def draw(canvas)
      bresenham_algorithm = BresenhamAlgorithm.new(@first_point,  @second_point)
      points = bresenham_algorithm.apply_on(canvas)
    end

      class BresenhamAlgorithm
    def initialize(from, to)
      prepare_coordinates_and_detect_steepness(from.x, from.y, to.x, to.y)
      prepare_deltas_and_initial_values
    end

    def apply_on(canvas)
      @steps.each do |x|
        canvas.set_pixel (@steep ? @y : x), (@steep ? x : @y)

        @error -= @delta_y

        if @error < 0
          @y += @y_step
          @error += @delta_x
        end
      end
    end

    private

    def prepare_coordinates_and_detect_steepness(from_x, from_y, to_x, to_y)
      @steep = (to_y - from_y).abs > (to_x - from_x).abs
      if @steep
        @from_x, @from_y = from_y, from_x
        @to_x, @to_y = to_y, to_x
      else
        @from_x, @from_y = from_x, from_y
        @to_x, @to_y = to_x, to_y
      end
    end

    def prepare_deltas_and_initial_values
      @delta_x = (@to_x - @from_x).abs
      @delta_y = (@to_y - @from_y).abs

      @error = @delta_x / 2

      @y_step = @from_y < @to_y ? 1 : -1

      @y = @from_y

      @steps = @from_x < @to_x ? @from_x.upto(@to_x) : @from_x.downto(@to_x)
    end
  end
  end

  class Rectangle
    attr_reader :left, :right

    def initialize(left, right)
      if left.x > right.x or (left.x == right.x and left.y > right.y)
        @left  = right
        @right = left
      else
        @left  = left
        @right = right
      end
    end

    def top_left
      Point.new left.x,  [left.y, right.y].min
    end

    def top_right
      Point.new right.x, [left.y, right.y].min
    end

    def bottom_right
      Point.new right.x, [left.y, right.y].max
    end

    def bottom_left
      Point.new left.x,  [left.y, right.y].max
    end

    def eql?(other)
      top_left == other.top_left and bottom_right == other.bottom_right
    end

    alias == eql?

    def hash
      top_left.hash & top_right.hash & bottom_left.hash & bottom_right.hash
    end

    def draw(canvas)
      Line.new(top_left, top_right).draw(canvas)
      Line.new(top_right, bottom_right).draw(canvas)
      Line.new(bottom_right, bottom_left).draw(canvas)
      Line.new(bottom_left, top_left).draw(canvas)
    end
  end

  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @field = Array.new(height){ Array.new(width){ false } }
    end

    def set_pixel(x, y)
      return if width <= x or height <= y
      @field[y][x] = true
    end

    def pixel_at?(x, y)
      @field[y][x]
    end

    def draw(figure)
      figure.draw(self)
    end

    def render_as(renderer_class)
      renderer = renderer_class.new
      renderer.render(@field)
    end
  end

  module Renderers
    class Renderer
      def render(field, full_pixel, blank_pixel, line_break_symbol)
        rendered_field = ''
        field.each_with_index do |row, index_row|
          row.each_with_index do |pixel, index_pixel|
            rendered_field << find_pixel(pixel, full_pixel, blank_pixel)
          end

          rendered_field << line_break_symbol
        end

        rendered_field
      end

      def find_pixel(pixel, full_pixel, blank_pixel)
        if pixel
          full_pixel
        else
          blank_pixel
        end
      end
    end

    class Ascii < Renderer
      def render(field)
        super(field, "@", "-", "\n").chop
      end
    end

    class Html < Renderer
      START_HTML = <<-eos
          <!DOCTYPE html>
          <html>
          <head>
            <title>Rendered Canvas</title>
            <style type="text/css">
              .canvas {
                font-size: 1px;
                line-height: 1px;
              }
              .canvas * {
                display: inline-block;
                width: 10px;
                height: 10px;
                border-radius: 5px;
              }
              .canvas i {
                background-color: #eee;
              }
              .canvas b {
                background-color: #333;
              }
            </style>
          </head>
          <body>
            <div class="canvas">
      eos

      END_HTML = <<-eos
           </div>
          </body>
          </html>
      eos

      def render(field)
        rendered_field = super(field, "<b></b>", "<i></i>", "<br>")
        "" << START_HTML << rendered_field[0..-5] << END_HTML
      end
    end
  end
end
#E:\GithubRepositories\Photoshop\ruby-retrospective-3\solutions\01.rb
#rspec E:\GithubRepositories\Photoshop\ruby-retrospective-3\specs\01_spec.rb --require E:\GithubRepositories\Photoshop\ruby-retrospective-3\solutions\01.rb  --colour --format documentation
#E:\GithubRepositories\Photoshop\ruby-retrospective-3\specs\03_spec.rb