# mongoid-rspec

[![Build Status](https://travis-ci.org/mgomes/mongoid-rspec.svg?branch=master)](https://travis-ci.org/mgomes/mongoid-rspec)

RSpec matchers for Mongoid 4.x with support for RSpec 3.x.

For Mongoid 2.x, use [mongoid-rspec 1.4.5](http://rubygems.org/gems/mongoid-rspec/versions/1.4.5)
For Mongoid 3.x, use [mongoid-rspec 1.11.0](http://rubygems.org/gems/mongoid-rspec/versions/1.11.0)

## Installation

Add to your Gemfile

  gem 'mongoid-rspec', github: 'mgomes/mongoid-rspec'

Drop in existing or dedicated support file in spec/support (spec/support/mongoid.rb)

```ruby
RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model
end
```

## Association Matchers

```ruby
describe User do
  it { is_expected.to have_many(:articles).with_foreign_key(:author_id).ordered_by(:title) }

  it { is_expected.to have_one(:record) }
  #can verify autobuild is set to true
  it { is_expected.to have_one(:record).with_autobuild }

  it { is_expected.to have_many :comments }

  #can also specify with_dependent to test if :dependent => :destroy/:destroy_all/:delete is set
  it { is_expected.to have_many(:comments).with_dependent(:destroy) }
  #can verify autosave is set to true
  it { is_expected.to have_many(:comments).with_autosave }

  it { is_expected.to embed_one :profile }

  it { is_expected.to have_and_belong_to_many(:children) }
  it { is_expected.to have_and_belong_to_many(:children).of_type(User) }
end

describe Profile do
  it { is_expected.to be_embedded_in(:user).as_inverse_of(:profile) }
end

describe Article do
  it { is_expected.to belong_to(:author).of_type(User).as_inverse_of(:articles) }
  it { is_expected.to belong_to(:author).of_type(User).as_inverse_of(:articles).with_index }
  it { is_expected.to embed_many(:comments) }
end

describe Comment do
  it { is_expected.to be_embedded_in(:article).as_inverse_of(:comments) }
  it { is_expected.to belong_to(:user).as_inverse_of(:comments) }
end

describe Record do
  it { is_expected.to belong_to(:user).as_inverse_of(:record) }
end

describe Site do
  it { is_expected.to have_many(:users).as_inverse_of(:site).ordered_by(:email.asc) }
end
```

## Mass Assignment Matcher

```ruby
describe User do
  it { is_expected.to allow_mass_assignment_of(:login) }
  it { is_expected.to allow_mass_assignment_of(:email) }
  it { is_expected.to allow_mass_assignment_of(:age) }
  it { is_expected.to allow_mass_assignment_of(:password) }
  it { is_expected.to allow_mass_assignment_of(:password) }
  it { is_expected.to allow_mass_assignment_of(:role).as(:admin) }

  it { is_expected.not_to allow_mass_assignment_of(:role) }
end
```

## Validation Matchers

```ruby
describe Site do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end

describe User do
  it { is_expected.to validate_presence_of(:login) }
  it { is_expected.to validate_uniqueness_of(:login).scoped_to(:site) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message("is already taken") }
  it { is_expected.to validate_format_of(:login).to_allow("valid_login").not_to_allow("invalid login") }
  it { is_expected.to validate_associated(:profile) }
  it { is_expected.to validate_exclusion_of(:login).to_not_allow("super", "index", "edit") }
  it { is_expected.to validate_inclusion_of(:role).to_allow("admin", "member") }
  it { is_expected.to validate_confirmation_of(:email) }
  it { is_expected.to validate_presence_of(:age).on(:create, :update) }
  it { is_expected.to validate_numericality_of(:age).on(:create, :update) }
  it { is_expected.to validate_inclusion_of(:age).to_allow(23..42).on([:create, :update]) }
  it { is_expected.to validate_presence_of(:password).on(:create) }
  it { is_expected.to validate_presence_of(:provider_uid).on(:create) }
  it { is_expected.to validate_inclusion_of(:locale).to_allow([:en, :ru]) }
end

describe Article do
  it { is_expected.to validate_length_of(:title).within(8..16) }
end

describe Profile do
  it { is_expected.to validate_numericality_of(:age).greater_than(0) }
end

describe MovieArticle do
  it { is_expected.to validate_numericality_of(:rating).to_allow(:greater_than => 0).less_than_or_equal_to(5) }
  it { is_expected.to validate_numericality_of(:classification).to_allow(:even => true, :only_integer => true, :nil => false) }
end

describe Person do
   # in order to be able to use the custom_validate matcher, the custom validator class (in this case SsnValidator)
   # is_expected.to redefine the kind method to return :custom, i.e. "def self.kind() :custom end"
  it { is_expected.to custom_validate(:ssn).with_validator(SsnValidator) }
end
```

## Accepts Nested Attributes Matcher

```ruby
describe User do
  it { is_expected.to accept_nested_attributes_for(:articles) }
  it { is_expected.to accept_nested_attributes_for(:comments) }
end

describe Article do
  it { is_expected.to accept_nested_attributes_for(:permalink) }
end
```

## Index Matcher

```ruby
describe Article do
  it { is_expected.to have_index_for(published: 1) }
  it { is_expected.to have_index_for(title: 1).with_options(unique: true, background: true) }
end

describe Profile do
  it { is_expected.to have_index_for(first_name: 1, last_name: 1) }
end
```

## Others

```ruby
describe User do
  it { is_expected.to have_fields(:email, :login) }
  it { is_expected.to have_field(:s).with_alias(:status) }
  it { is_expected.to have_fields(:birthdate, :registered_at).of_type(DateTime) }

  # if you're declaring 'include Mongoid::Timestamps'
  # or any of 'include Mongoid::Timestamps::Created' and 'Mongoid::Timestamps::Updated'
  it { is_expected.to be_timestamped_document }
  it { is_expected.to be_timestamped_document.with(:created) }
  it { is_expected.not_to be_timestamped_document.with(:updated) }

  it { is_expected.to be_versioned_document } # if you're declaring `include Mongoid::Versioning`
  it { is_expected.to be_paranoid_document } # if you're declaring `include Mongoid::Paranoia`
  it { is_expected.to be_multiparameted_document } # if you're declaring `include Mongoid::MultiParameterAttributes`
end

describe Log do
  it { is_expected.to be_stored_in :logs }
end

describe Article do
  it { is_expected.to have_field(:published).of_type(Boolean).with_default_value_of(false) }
  it { is_expected.to have_field(:allow_comments).of_type(Boolean).with_default_value_of(true) }
  it { is_expected.not_to have_field(:allow_comments).of_type(Boolean).with_default_value_of(false) }
  it { is_expected.not_to have_field(:number_of_comments).of_type(Integer).with_default_value_of(1) }
end
```

## Acknowledgement

Thanks to [Durran Jordan](https://github.com/durran) for providing the changes necessary to make
this compatible with mongoid 2.0.0.rc, and for other [contributors](https://github.com/evansagge/mongoid-rspec/contributors)
to this project.
