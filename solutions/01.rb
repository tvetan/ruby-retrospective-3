class Integer
  def prime?
    return false if self < 2
    2.upto(Math.sqrt(abs)).all? { |number| abs % number != 0 }
  end

  def prime_factors
    find_prime_factors([], 2, self)
  end

  def find_prime_factors(list_of_divisors, current_divisor, current_number)
    while current_divisor <= abs
      if current_divisor.prime? and current_number % current_divisor == 0
        list_of_divisors << current_divisor
        current_number = current_number / current_divisor
      else
        current_divisor += 1
      end
    end

    list_of_divisors
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

  def combine_with(other_list)
    smallest_length = other_list.length < length ? other_list.length : length
    combined_list = []
    (0..smallest_length - 1).each do |number|
      combined_list << self[number] << other_list[number]
    end
    combined_list << other_list.drop(smallest_length) << drop(smallest_length)

    combined_list.flatten
  end
end