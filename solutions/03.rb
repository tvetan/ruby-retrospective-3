module Graphics
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def eql? (other_point)
      @x.eql?(other_point.x) and @y.eql? (other_point.y)
    end

    def draw(canvas)
      canvas.set_pixel(@x, @y)
    end

    def ==(other_point)
      eql?(other_point)
    end

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

    def ==(other_line)
      eql?(other_line)
    end

    def hash
      @first_point.hash & @second_point.hash
    end

    def draw(canvas)
      bresenham_algorithm = BresenhamAlgorithm.new(@first_point, @second_point)
      points = bresenham_algorithm.calculate
      points.each { |point| canvas.set_pixel(point.x, point.y) }
    end
  end

  class Rectangle
    attr_reader :first_point, :second_point, :points

    def initialize(first_point, second_point)
      @first_point = first_point
      @second_point = second_point
      @third_point = Point.new(first_point.x, second_point.y)
      @fourth_point = Point.new(second_point.x, first_point.y)
      @points = [@first_point, @second_point, @third_point, @fourth_point]
    end

    def get_left_point(first_point, second_point)
      if first_point.x == second_point.x
        return first_point.y > second_point.y ? second_point : first_point
      end

      return first_point.x > second_point.x ? second_point : first_point
    end

    def left
      get_left_point @first_point, @second_point
    end

    def right
      if @first_point.x == @second_point.x
        return @first_point.y < @second_point.y ? @second_point : @first_point
      end

      return @first_point.x < @second_point.x ? @second_point : @first_point
    end

    def top_left
      sorted_points = @points.sort do |first_point, second_point|
        first_point.x > second_point.x ? 1 : first_point.y <=> second_point.y
      end

      sorted_points[0]
    end

    def bottom_left
      sorted_points = @points.sort do |first_point, second_point|
        first_point.x > second_point.x ? 1 : second_point.y <=> first_point.y
      end

      sorted_points[0]
    end

    def bottom_right
      sorted_points =  @points.sort do |first_point, second_point|
        first_point.y < second_point.y ? 1 : second_point.x <=> first_point.x
      end

      sorted_points[0]
    end

    def top_right
      sorted_points = @points.sort do |first_point, second_point|
        first_point.y > second_point.y ? 1 : second_point.x <=> first_point.x
      end

      sorted_points[0]
    end

    def eql? (other_rectangle)
      top_left.eql?(other_rectangle.top_left) and
      top_right.eql?(other_rectangle.top_right) and
      bottom_left.eql?(other_rectangle.bottom_left) and
      bottom_right.eql?(other_rectangle.bottom_right)
    end

    def ==(other_rectangle)
      eql?(other_rectangle)
    end

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

  class BresenhamAlgorithm
    def initialize(first_point, second_point)
      @first_point_x, @first_point_y = first_point.x, first_point.y
      @second_point_x, @second_point_y = second_point.x, second_point.y
      initialize_step
      initialize_coordinates
      initialize_deltas
    end

    def initialize_step
      difference_y = (@second_point_y - @first_point_y).abs
      difference_x = (@second_point_x - @first_point_x).abs
      @steep = difference_y > difference_x
    end

    def initialize_deltas
      @delta_x = @second_point_x - @first_point_x
      @delta_y = (@second_point_y - @first_point_y).abs
      @error = @delta_x / 2
      @step_y = @first_point_y < @second_point_y ? 1 : -1
    end

    def initialize_coordinates
      if @steep
        @first_point_x, @first_point_y = @first_point_y, @first_point_x
        @second_point_x, @second_point_y = @second_point_y, @second_point_x
      end

      if @first_point_x > @second_point_x
        @first_point_x, @second_point_x = @second_point_x, @first_point_x
        @first_point_y, @second_point_y = @second_point_y, @first_point_y
      end
    end

    def calculate
      points = []

      @first_point_x.upto(@second_point_x) do |x|
        points << (@steep ? Point.new(@first_point_y, x) : Point.new(x, @first_point_y))
        increment_position
      end

      points
    end

    def increment_position
      @error = @error - @delta_y
      if @error <= 0
        @first_point_y = @first_point_y + @step_y
        @error = @error + @delta_x
      end
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