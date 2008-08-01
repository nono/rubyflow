class Item < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  
  serialize :metadata
  
  attr_protected :user_id
  
  validates_length_of       :title, :within => 4..255
  validates_uniqueness_of   :name, :if => :name?
  validates_format_of       :name, :with => /^[\w\-\_]+$/, :if => :name?, :message => "n'est pas valide (caractères alphanumériques, tiret et underscore uniquement)'"
  validates_length_of       :name, :within => 4..255, :if => :name?
  validates_length_of       :content, :within => 25..1200
  validates_format_of       :tags, :with => /^[\s\w\-\_\:]+$/, :if => :tags?, :message => "ne sont pas valides (caractères alphanumériques, tiret et underscore uniquement)'"
  
  def to_param
    self[:name] && self[:name].length > 3 ? self[:name] : self[:id]
  end
  
  def tags=(tag_set)
    self[:tags] = tag_set.split.collect { |a| " :#{a} " }.join
  end
  
  def tags_before_type_cast
    self[:tags].to_s.gsub(':', '').gsub(/[^\w\s\-\_\:].+?\s+/, ' ').gsub(/[^\w\s\-\_\:]/, '').strip.split(/\s+/).join(' ')
  end

  def tags
    tags_before_type_cast
  end
  
  def tag_array
    tags.split(/\s+/)
  end
  
  def self.find_all_for_all_tags(tags, options = {})
    find(:all, { :conditions => [[*tags].collect { "tags LIKE ?" }.join(" AND "), *[*tags].collect { |a| "%:#{a} %" }] }.merge(options))
  end
  def self.count_all_for_all_tags(tags, options = {})
    count({ :conditions => [[*tags].collect { "tags LIKE ?" }.join(" AND "), *[*tags].collect { |a| "%:#{a} %" }] }.merge(options))
  end

  def self.find_all_for_tag(tag, options = {})
    find(:all, { :conditions => ["tags LIKE ?", "%#{tag}%"] }.merge(options))
  end
  def self.count_all_for_tag(tag, options = {})
    count({ :conditions => ["tags LIKE ?", "%#{tag}%"] }.merge(options))
  end

  def self.find_all_for_tags(tags, options = {})
    find(:all, { :conditions => [[*tags].collect { "tags LIKE ?" }.join(" OR "), *[*tags].collect { |a| "%:#{a} %" }] }.merge(options))
  end
  def self.count_all_for_tags(tags, options = {})
    count({ :conditions => [[*tags].collect { "tags LIKE ?" }.join(" OR "), *[*tags].collect { |a| "%:#{a} %" }] }.merge(options))
  end  
end
