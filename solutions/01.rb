class Integer
  def prime?
    return false if self < 2
    2.upto(Math.sqrt(abs)).all? { |number| abs % number != 0 }
  end

  def prime_factors
    return [] if abs < 2
    divisor = 2.upto(abs).find { |divisor| remainder(divisor).zero? }
    [divisor] + (abs / divisor).prime_factors
  end

  def harmonic
    return if self <= 0
    (1..self).map { |e| 1 / e.to_r }.reduce(:+)
  end

  def digits
    abs.to_s.chars.map { |e| e.to_i }
  end
end

class Array
  def average
    return if empty?
    reduce(0.0, :+) / length
  end

  def drop_every(n)
    result = []
    each_index { |index| result << self[index] if (index + 1) % n != 0 }

    result
  end

  def frequencies
    occurrences = Hash.new(0)
    each { |number| occurrences[number] += 1 }

    occurrences
  end

  def combine_with(other)
    smaller_size = [size, other.size].min
    remainder = drop(smaller_size) + other.drop(smaller_size)
    zip(other).flatten(1).take(2 * smaller_size) + remainder
  end
end