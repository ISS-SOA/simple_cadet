module StoryHelpers
  def random_str(n)
    (0..n).map { ('a'..'z').to_a[rand(26)] }.join
  end
end
