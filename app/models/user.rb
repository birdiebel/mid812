class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "email", "actif", "encrypted_password", "id", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "player" ]
  end

  has_one :player
  accepts_nested_attributes_for :player
  validates :email, presence: true


  enum :role, [ :player, :admin ]
end
