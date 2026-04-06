# MK-469 Remove Users from Inactive Districts in MailChimp
# 1. Export all users where District = Inactive AND said user is not in another Active district. 
# 2. Tag these emails as “District Inactive” in MailChimp https://us5.admin.mailchimp.com/lists/tags/bulk-tag/
# 3. Go to Audience and filter by tag “District Inactive”.
# 4. Archive from MailChimp these users.


# get users from DB

require 'csv'


def users_from_inactive_districts
  file = "/Users/terrythomas/users_from_inactive_districts.csv"

  db_contacts = []

  inactive_districts = District.where(active: false).select(:id)
  active_district_users = User.joins(:districts).where(districts: { active: true }).distinct.select(:id)


  User.joins(:districts).where(districts: { id: inactive_districts }).select(:email).where.not(id: active_district_users).in_batches(of: 10000) do | batch |
    batch.pluck(:email).each do | email |
      db_contacts << email
    end
  end

  CSV.open(file, 'w') do | writer |
    db_contacts.each do | email | 
      writer << [email]
    end
  end
end


# bulk tag those users in MC


# archive those users in MC


