class User < ActiveRecord::Base
  validates :postcode, presence: true
  validates :name, presence: true


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      if find_by_email(auth.info.email) 
        return user
      end
      user.uid = auth.uid
      user.provider = auth.provider
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = auth.info.email
      user.image = auth.info.image.split("?")[0]
      user.gender = auth[:extra][:raw_info][:gender]
      user.birthday = auth.extra.raw_info.birthday
    end
  end

  has_many :conversations, :foreign_key => :sender_id
end