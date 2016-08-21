#!/usr/bin/env ruby
require 'pp'
require 'set'

Point = Struct.new(:x, :y) do
  def euclidean_distance(b)
    Math::sqrt((x - b.x)**2 + (y - b.y)**2)
  end

  alias :distance euclidean_distance

  def to_centroid
    Centroid.new(x, y)
  end

  def to_s
    "[#{x},#{y}]"
  end

  def dump(color=0, label='')
    [self.x, self.y, color, "\"#{label}\""].join(',')
  end

  def print_dump(color=0, label='')
    puts dump(color, label)
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
    new_distance = distance Point.new(mean.x, mean.y)
    self.x, self.y = mean.x, mean.y
    new_distance
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
    @centroids = pick_centroids :random

    30.times do |i|
      @data.each_with_index do |point, index|
        prev_centroid, prev_centroid_index = previous_centroid point
        centroid, centroid_index = nearest_centroid point
        @centroids[prev_centroid_index].remove(point) if prev_centroid && prev_centroid_index != centroid_index
        @centroids[centroid_index].set(point)
      end

      new_means = @centroids.map(&:update_mean!)
      return if new_means.inject(0.0) { |sum, d| sum +=d } === 0.0

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

KMeans.new(7, POINTS).run
