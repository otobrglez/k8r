#!/usr/bin/env ruby
require 'pp'
require 'set'

Point = Struct.new(:x, :y) do
  def euclidean_distance(b)
    Math::sqrt((x - b.x)**2 + (y - b.y)**2)
  end

  alias :distance euclidean_distance

  def to_s
    "[#{x},#{y}]"
  end

  def dump(color=0, label='')
    [self.x, self.y, color, "\"#{label}\""].join(',')
  end

  def print_dump(color=0, label='')
    puts dump(color, label)
  end

  def to_centroid
    Centroid.new(x, y)
  end
end

Centroid = Class.new(Point) do
  attr_reader :points

  def initialize(x, y, points = [])
    super(x, y)
    @points = points
  end

  def mean
    @mean ||= Point.new(*@points.inject([0, 0]) do |sum, point|
      sum.tap { |s| s[0] += point.x; s[1] += point.y }
    end.map { |p| p.to_f / @points.size })
  end

  def update_mean!
    self.x = mean.x
    self.y = mean.y
    # self.y = , mean.y # if self.x != x or self.y != y
  end

  def set(point)
    points.push(point) unless has?(point)
  end

  def has?(point)
    points.include?(point)
  end

  def remove(point)
    points.delete(point)
  end
end

# POINTS = DATA.read.split("\n").map { |l| l.split(',').map(&:to_i) }.map { |p| Point.new(*p) }

POINTS = [[80, 55], [86, 59], [19, 85], [41, 47], [57, 58],
          [76, 22], [94, 60], [13, 93], [90, 48], [52, 54],
          [62, 46], [88, 44], [85, 24], [63, 14], [51, 40],
          [75, 31], [86, 62], [81, 95], [47, 22], [43, 95],
          [71, 19], [17, 65], [69, 21], [59, 60], [59, 12],
          [15, 22], [49, 93], [56, 35], [18, 20], [39, 59],
          [50, 15], [81, 36], [67, 62], [32, 15], [75, 65],
          [10, 47], [75, 18], [13, 45], [30, 62], [95, 79],
          [64, 11], [92, 14], [94, 49], [39, 13], [60, 68],
          [62, 10], [74, 44], [37, 42], [97, 60], [47, 73]].map { |p| Point.new(*p) }

class KMeans
  attr_reader :k, :data, :centroids

  def initialize(k, data)
    @k, @data = k, data
    @centroids = []
  end

  def run
    @centroids = pick_centroids :first # :random # :first # :random

    # dump_frame './steps/step-000.dat'

    20.times do |i|
      @data.each_with_index do |point, index|
        prev_centroid, prev_centroid_index = previous_centroid point
        centroid, centroid_index = nearest_centroid point

        if prev_centroid && prev_centroid_index != centroid_index
          @centroids[prev_centroid_index].remove(point)
        end

        @centroids[centroid_index].set(point)
      end

      @centroids.map(&:update_mean!)
      dump_frame './steps/step-%03d.dat' % [i]
    end

    dump_frame
  end

  def pick_centroids(mode = :first)
    return data[0, k].map(&:to_centroid) if mode == :first
    data.sample(k).map(&:to_centroid) # Random pick
  end

  def nearest_centroid(point)
    @centroids.each_with_index.min_by { |centroid, i| [centroid.distance(point), i] }
  end

  def previous_centroid(point)
    @centroids.each_with_index.find { |centroid, i| [centroid.has?(point), i] }
  end

  def dump_frame(filename='')
    buffer = ''

    @centroids.each_with_index do |centroid, i|
      centroid.points.each do |p|
        buffer += p.dump(i+1) + "\n"
      end

      buffer += centroid.dump(0, 'centroid') + "\n"
    end

    puts buffer
    File.open(filename, 'w') { |f| f.write(buffer) } if filename != ''
  end

  def each(&block)
    yield block if block_given?
  end
end

m = KMeans.new(5, POINTS)
m.run

exit 0
puts
puts 'Report:'
m.centroids.each_with_index do |centroid, i|
  puts "#{centroid} centroid #{i}"
  centroid.points.each do |p|
    puts "#{p}"
  end
end

# K-Means++ = finding best "k"
# Elbow = finding cluster with minimal distorsion http://www.edureka.co/blog/k-means-clustering/

=begin
6,5
9,1
10,1
5,5
7,7
4,1
10,7
6,8
10,2
9,4
2,5
9,1
10,9
2,8
1,1
6,1
3,8
2,3
7,9
7,7
3,6
5,8
7,5
10,9
10,9
=end
__END__
185,72
170,56
168,60
179,68
182,72
188,77
180,71
180,70
183,84
180,88
180,67
177,76
