class Racer
  include ActiveModel::Model
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs
  
  #returns a MongoDB client configured to communicate to the default database
  def self.mongo_client
  	Mongoid::Clients.default
  end

  def self.collection
  	self.mongo_client['racers']
  end

  def initialize(params={})
    @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end

  def self.all(prototype={}, sort={:number=>1}, offset=0, limit=nil)
    Rails.logger.debug {"getting all racers, prototype=#{prototype}, sort=#{sort}, offset=#{offset}, limit=#{limit}"}

    #returns collection depending on parameters
    result = collection.find(prototype).sort(sort).skip(offset)
    result = result.limit(limit) if !limit.nil?
    return result
  end

  def self.find(id)
    result = collection.find({:_id => BSON::ObjectId.from_string(id)}).first
    result.nil? ? nil : Racer.new(result)
  end

  def save
    result = self.class.collection
                 .insert_one(number: @number, first_name: @first_name, 
                             last_name: @last_name, gender: @gender,
                             group: @group, secs: @secs)
    @id = result.inserted_id.to_s
  end
end
