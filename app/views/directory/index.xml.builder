# frozen_string_literal: true

xml.instruct!

xml.staffdir do
  xml.pubDate Time.zone.now.strftime('%c %Z')
  xml.totalUids @people.length
  xml.totalPublishedEntries @people.length
  xml.totalUnpublishedEntries 0

  xml.entries do
    @people.each do |p|
      xml.entry do
        xml.published 1
        xml.sunetid p.uid
        xml.mail p.mail
        xml.telephonenumber Array(p.telephoneNumber).join(', ')
        xml.displayname p.displayName
        xml.sudisplaynamefirst p.suDisplayNameFirst
        xml.sudisplaynamelast p.suDisplayNameLast
        xml.title p.title
        xml.org_id p.suPrimaryOrganizationID
        xml.org_name p.suPrimaryOrganizationName
      end
    end
  end
end
