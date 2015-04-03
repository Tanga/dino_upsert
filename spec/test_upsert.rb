require_relative 'setup'
class TestUpsert < Dino::TestCase
  def test_upsert_no_conditions
    ns = nil
    assert_difference "NewsletterSubscription.count" do
      ns = Dino::Upsert.upsert(NewsletterSubscription, {email_address: 'bob@tanga.com'})
    end
    assert_equal 'bob@tanga.com', ns.email_address

    assert_no_difference "NewsletterSubscription.count" do
      ns = Dino::Upsert.upsert(NewsletterSubscription, {email_address: 'bob@tanga.com'})
    end
    assert_equal 'bob@tanga.com', ns.email_address
  end

  def test_upsert_with_conditions
    ns = nil
    assert_difference "NewsletterSubscription.count" do
      ns = Dino::Upsert.upsert(
             NewsletterSubscription,
             {email_address: 'bob@tanga.com'},
             lol_subscription: true, first_name: 'joe') do |obj|
               obj.gender = 'male'
             end
    end
    assert_equal 'bob@tanga.com', ns.email_address
    assert_equal true, ns.lol_subscription
    assert_equal 'male', ns.gender
    assert_equal 'joe', ns.first_name

    assert_no_difference "NewsletterSubscription.count" do
      ns = Dino::Upsert.upsert(NewsletterSubscription, {email_address: 'bob@tanga.com'},
                                                        lol_subscription: false)
    end
    assert_equal 'bob@tanga.com', ns.email_address
    assert_equal false, ns.lol_subscription
    assert_equal 'male', ns.gender
    assert_equal 'joe', ns.first_name
  end

  def test_race_conditions
    assert_difference "NewsletterSubscription.count" do
      Dino::Upsert.upsert(NewsletterSubscription, email_address: 'bob@tanga.com') do |_obj|
        # Insert another row after the first check failed
        Dino::Database.sequel do |db|
          db[:newsletter_subscriptions].insert(email_address: 'bob@tanga.com')
        end
      end
    end
  end
end
