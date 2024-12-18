class UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  # Cache the serialization for 1 hour since user data changes less frequently
  cache key: "user", expires_in: 1.hour
end
